class UploadParserService < PowerTypes::Service.new(:u)

  def run
    @klass = Object.const_get @u.model.classify
    sheet = Roo::Spreadsheet.open(@u.file, clean: true)
    headers = hts.model_fields_to_pt(@u.model)
    hash_tables = build_hash_tables
    compare_headers(sheet, headers)
    new_entries = []
    accept_file = true
    sheet.parse(headers).each_with_index do |row, index|
      row_n = index + 2
      puts "Processing sheet row ##{row_n}" if (row_n % 100).zero?
      row_tr_enums = translate_enum_fields(row) if @klass.is_a?(Enumerize)
      row.merge!(row_tr_enums) if row_tr_enums.present?
      if @u.model.to_s == 'quote'
        # Freight Subtype
        row[:freight_subtype] = tr_freight_subtype row[:freight_subtype]
        # Set Current if watched
        row[:current] = !!row[:watched]
      end
      obj = BuildObjectFromRow.for(model: @u.model, row: row, hash_tables: hash_tables)
      obj.set_code if obj.class.name == 'Quote'
      # TODO fix simulate called twice, obj.valid? (L21) and @klass.import new_entries (L34)
      if !obj.errors.any? && obj.valid?
        new_entries << obj
      else
        accept_file = false
        obj.errors.full_messages.each do |error_msg|
          row_error(row_n, error_msg)
        end
      end
    end

    if accept_file && !@u.errors.any?
      attr_fields = @klass.xls_fields.select {|_k, v| v == :attr }.keys
      attr_fields << :display_name if @klass.method_defined?(:set_display_name)
      @klass.import new_entries, on_duplicate_key_update: { conflict_target: [:id], columns: attr_fields }
      @u.records = new_entries
      deprecate_ex_currents(new_entries) if @u.model.to_s == 'quote'
      true
    else
      false
    end
  end

  def compare_headers(sheet, headers)
    diff = sheet.row(1) - headers.values
    unless diff.empty?
      error("Cabeçalho de coluna inesperado: #{diff}")
    end
  end

  def hts
    @hts ||= HeaderTranslatorService.new
  end

  def row_error(row_n, msg)
    error "Fila ##{row_n}: #{msg}"
  end

  def error(msg, attr = :base)
    @u.errors.add(attr, msg)
  end

  def build_hash_tables
    hash_tables = {}
    f_key_fields = @klass.xls_fields.select {|_k, v| v == :f_key }.keys
    f_key_fields.each do |f_key_field|
      f_model, f_field = f_key_field.to_s.split('.')
      f_class = Object.const_get f_model.classify
      # hash_tables[f_key_field] = f_class.pluck(f_field, :id).map { |row| [row.first.to_s, row.last.to_s] }.to_h
      hash_tables[f_key_field] = f_class.all.map { |obj| [obj.send(f_field).to_s, obj] }.to_h
    end
    hash_tables
  end

  def translate_enum_fields(row)
    @enum_cols ||= @klass.enumerized_attributes.attributes.keys
    row.select { |k,v| @enum_cols.include?(k.to_s)}.map do |k,v|
      [k, hts.enum_field_to_en(@u.model, k, v)]
    end.to_h
  end

  def tr_freight_subtype(pt_subtype)
    @cbf_translations ||=
      Quote::PACKED_SUBTYPES.merge(Quote::SPECIAL_SUBTYPES).merge(Quote::BULK_BASIC_SUBTYPES).merge(ChoppedBulkFreight.translations).invert
    @cbf_translations[pt_subtype].to_s
  end

  def deprecate_ex_currents(new_quotes)
    codes_to_update = new_quotes.select(&:watched).map(&:code).compact
    Quote.where(current: true, code: codes_to_update)
        .where.not(id: new_quotes.map(&:id))
        .update_all(current: false)
  end
end
