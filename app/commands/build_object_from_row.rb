class BuildObjectFromRow < PowerTypes::Command.new(:model, :row, :hash_tables)
  def perform
    @klass = Object.const_get @model.to_s.classify
    @errors = []
    @foreign_fields = fetch_foreigns
    @obj = build_obj
    update_display_names if @klass.method_defined?(:set_display_name)
    @errors.each { |err_msg| @obj.errors.add(:base, err_msg) }
    @obj
  end

  def build_obj
    return build_for_watched_quote if @model == 'quote' && @row[:watched] && @row[:code_if_watched].present?
    case @klass.xls_mode
      when :create
        build_for_create_mode
      when :update
        build_for_update_mode
    end
  end

  def build_for_watched_quote
    aux = { code: @row[:code_if_watched] }
    aux.merge!(@foreign_fields.except('vehicle', 'dist_center', 'city'))
    quote = Quote.where(aux).order('id ASC').last&.dup
    unless quote
      raise "Não foi encontrada monitoreada codigo ##{@row[:code_if_watched]} para usuário/produto/cliente indicado"
    end
    quote.assign_attributes(fields_of_type(:attr).merge(@foreign_fields).merge(ancestor_quote_id: quote.id))
    quote
  end

  def build_for_update_mode
    if @model.include? 'freight'
      aux = fields_of_type(:key).merge(@foreign_fields)
      obj = @klass.find_or_initialize_by(aux)
      obj.assign_attributes(fields_of_type(:attr))
    else
      obj = @klass.find_or_initialize_by(fields_of_type(:key))
      obj.assign_attributes(fields_of_type(:attr).merge(@foreign_fields))
    end
    obj
  end

  def build_for_create_mode
    @klass.new(fields_of_type(:attr).merge(@foreign_fields))
  end

  def fetch_foreigns
    fields_of_type(:f_key).map do |key, value|
      f_model, f_field = key.to_s.split '.'
      f_obj = fetch_foreign_field(f_model, f_field, value)
      [f_model, f_obj]
    end.to_h
  end

  def fetch_foreign_field(f_model, f_field, value)
    f_obj = @hash_tables["#{f_model}.#{f_field}".to_sym][value.to_s]
    if f_obj.nil? && value.present?
      raise "No #{f_model.titleize} found with #{f_field} #{value}"
    end
    f_obj
  rescue StandardError => e
    @errors << e.to_s
    nil
  end

  def update_display_names
    @obj.set_display_name
  end

  def headers_of_type(type)
    @klass.xls_fields.select { |_k, v| v == type}
  end

  def fields_of_type(type)
    @row.select { |key, _v| headers_of_type(type).include? key }
  end

  def hts
    @hts ||= HeaderTranslatorService.new
  end
end
