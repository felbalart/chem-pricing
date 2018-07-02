class BuildXlsx < PowerTypes::Command.new(:quotes)

  def perform
    preload_associations
    add_headers_row
    set_styles
    @quotes.each_with_index { |q, i| build_row(q, i + 1) }
    book.save(file_path)
    file_path
  end

  def preload_associations
    if @quotes.is_a?(Array)
      @quotes = Quote.where(id: @quotes.map(&:id))
    end
    @quotes = @quotes.preload(:user, :customer, :dist_center, :product, :cost, :optimal_markup, :vehicle, :city)
  end

  def fields
    {
      id: "Id",
      user_email: "Email - Usuario",
      customer_code: "Codigo Cliente",
      customer_name: "Nome Cliente",
      dist_center_code: "Codigo - CD",
      product_sku: "SKU - Produto",
      product_name: "Nome Produto",
      product_alias: "Nome Comercial Produto",
      quantity: "Quantidade Cotação",
      packaging: "Embalagem",
      quote_currency: "Moeda Cotação",
      quote_unit: "Unidade Cotação",
      converted_base_price: "Preço Piso",
      cost_suggested_markup: "Política",
      markup_value: "MarkUp Meta - Politica de MarkUp",
      quote_markup: "MarkUp Calculado (%)",
      quote_fob_net_price: "Preco Fob Net ($/UN)", # formula
      ptax: "PTAX",
      conversion: "Conversão kg-lt",
      quote_unit_price: "Preco Unitario ($)", # formula
      quote_currency_unit: "Moeda/Unidade", # formula
      quote_last_month_price: "PREÇO Mês Anterior",
      quote_last_month_delta: "Varia. Mês%", # formula
      quote_freight_conditions: "Condicoes de Frete",
      quote_unit_freight: "Frete ($/UN)",
      quote_icms: "ICMS",
      quote_pis_confins: "Pis/Confins",
      quote_ipi: "IPI",
      quote_payment_term: "Prazo de Pagamento (dias)",
      quote_payment_term_description: "Descrição Prazo",
      quote_encargos: "ENCARGO", # formula
      markup_table_value: "MarkUp Tabela - Politica de MarkUp",
      product_density: "Densidade",
      quote_observation: "Observação",
      quote_current: "Custo atual.",
      quote_city: "Itinerario - Municipio",
      quote_freight_type: "Tipo", # include subtype
      quote_vehicle: "Nome - Veiculo",
      customer_city: "Cidade/Estado do Cliente (Itinerario - Municipio)",
      freight_plus_taxes: 'Frete + Impostos ($/UN)', # formula
      quote_fob_final_price: 'Preço Final FOB ($/UN)', # formula
      quote_code_if_watched: "Código Monitorada"
    }
  end

  def column_widths
    {
      id: 30,
      user_email: 125,
      customer_code: 87,
      customer_name: 87,
      dist_center_code: 65,
      product_sku: 87,
      product_name: 90,
      product_alias: 90,
      quantity: 65,
      packaging: 65,
      quote_currency: 65,
      quote_unit: 65,
      converted_base_price: 65,
      cost_suggested_markup: 65,
      markup_value: 80,
      quote_markup: 80,
      quote_fob_net_price: 80,
      ptax: 65,
      conversion: 70,
      quote_unit_price: 85,
      quote_currency_unit: 65,
      quote_last_month_price: 65,
      quote_last_month_delta: 65,
      quote_freight_conditions: 65,
      quote_unit_freight: 65,
      quote_icms: 35,
      quote_pis_confins: 55,
      quote_ipi: 35,
      quote_payment_term: 65,
      quote_payment_term_description: 90,
      quote_encargos: 65,
      markup_table_value: 80,
      product_density: 65,
      quote_observation: 65,
      quote_current: 65,
      quote_city: 180,
      quote_freight_type: 110,
      quote_vehicle: 90,
      customer_city: 170,
      freight_plus_taxes: 80,# formula
      quote_fob_final_price: 80,# formula
      quote_code_if_watched: 87
    }
  end

  def add_headers_row
    fields.values.each_with_index do |pt_name, col|
      sheet.add_cell(0, col, pt_name)
    end
  end

  def build_row(q, row_index)
    fields.keys.each_with_index do |field, col_index|
      value = send("#{field}_column", q, row_index + 1)
      if value.is_a?(Array) # has format
        sheet.add_cell(row_index, col_index, value.first)
        sheet[row_index][col_index].set_number_format value.last
      elsif value.is_a?(Hash) # is a formula
        formula = value[:formula]
        format = value[:format]
        sheet.add_cell(row_index, col_index, '', formula)
        sheet[row_index][col_index].set_number_format format if format
      else
        sheet.add_cell(row_index, col_index, value)
      end
    end
  end

  BLUE_HEADER_COLUMNS = [:quote_markup, :quote_fob_net_price, :quote_unit_price, :quote_currency_unit,
    :quote_last_month_delta, :quote_encargos, :freight_plus_taxes, :quote_fob_final_price]

      def set_styles
    blue_header_indexes = BLUE_HEADER_COLUMNS.map { |col_name| fields.keys.find_index(col_name) }
    sheet.change_row_height(0, 30)
    fields.count.times do |col_i|
      fill_color = col_i.in?(blue_header_indexes) ? '0073BB' : 'E6005B'
      sheet.sheet_data[0][col_i].change_fill(fill_color)
      sheet.sheet_data[0][col_i].change_font_bold(true)
      sheet.sheet_data[0][col_i].change_font_color('FFFFFF')
      sheet.change_row_vertical_alignment(0, 'center')
      sheet.sheet_data[0][col_i].change_border(:bottom, 'thin')
      sheet.sheet_data[0][col_i].change_border(:right, 'thin')
    end

    pixels_per_cm = 6.0 # value must be given in cm
    column_widths.values.each_with_index do |width, col_index|
      sheet.change_column_width(col_index, width / pixels_per_cm)
    end
  end

  def book
    @book ||= RubyXL::Workbook.new
  end

  def sheet
    @sheet ||= book[0]
  end

  def file_path
    @file_path ||= begin
      timestamp = Time.current.to_json.gsub(':','-')[1..19]
      "#{Rails.root}/tmp/cotacoes-#{timestamp}.xlsx"
    end
  end

  # number transformation methods
  def to_money(num)
    [num, '$###,###.00']
  end

  def to_percentage(num)
    [num, '0%']
  end

  # columns values methods

  def id_column(q, _row_num)
    q.id
  end

  def user_email_column(q, _row_num)
    q.user.email
  end

  def customer_code_column(q, _row_num)
    q.customer&.code
  end

  def customer_name_column(q, _row_num)
    q.customer&.name
  end

  def dist_center_code_column(q, _row_num)
    q.dist_center.code
  end

  def product_sku_column(q, _row_num)
    q.product.sku
  end

  def product_name_column(q, _row_num)
    q.product.name
  end

  def product_alias_column(q, _row_num)
    q.product_alias
  end

  def quantity_column(q, _row_num)
    q.quantity
  end

  def packaging_column(q, _row_num)
    p_code = q.product.packaging_code
    packaging_hash[p_code.to_i]
  end

  def quote_currency_column(q, _row_num)
    q.currency_text
  end

  def quote_unit_column(q, _row_num)
    q.unit_text
  end

  def converted_base_price_column(q, _row_num)
    to_money q.converted_base_price
  end

  def markup_value_column(q, _row_num)
    to_percentage q.optimal_markup&.value
  end

  def quote_markup_column(q, _row_num)
    to_percentage q.markup
  end

  def quote_fob_net_price_column(_q, row_num)
    r = row_num
    {
      formula: "=IFERROR(IF(AND(R#{r}=\"\",S#{r}=\"\"),(M#{r}*(1+P#{r})),IF(AND(R#{r}<>\"\",S#{r}=\"\"),(M#{r}*R#{r}*(1+P#{r})),IF(AND(R#{r}=\"\",S#{r}<>\"\",L#{r}=\"KG\"),(M#{r}*AG#{r}*(1+P#{r})),IF(AND(R#{r}=\"\",S#{r}<>\"\",L#{r}=\"L\"),(M#{r}/AG#{r}*(1+P#{r})),IF(AND(R#{r}<>\"\",S#{r}<>\"\",L#{r}=\"KG\"),(M#{r}*R#{r}*AG#{r}*(1+P#{r})),IF(AND(R#{r}<=\"\",S#{r}<>\"\",L#{r}=\"LT\"),(M#{r}*R#{r}/AG#{r}*(1+P#{r})),\"-\")))))),\"-\")",
      format: '$###,###.00'
    }
  end

  def ptax_column(_q, _row_num)
    nil # leave blank!
  end

  def conversion_column(_q, _row_num)
    nil # leave blank!
  end

  def quote_unit_price_column(_q, row_num)
    r = row_num
    {
      formula:
        "=IF(AND(R#{r}=\"\",S#{r}=\"\"),((Q#{r}+Y#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r}),IF(AND(R#{r}<>\"\",S#{r}=\"\"),((Q#{r}+Y#{r}*R#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r}),IF(AND(R#{r}=\"\",S#{r}<>\"\",L#{r}=\"KG\"),((Q#{r}+Y#{r}*AG#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r}),IF(AND(R#{r}=\"\",S#{r}<>\"\",L#{r}=\"L\"),((Q#{r}+Y#{r}/AG#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r}),IF(AND(R#{r}<>\"\",S#{r}<>\"\",L#{r}=\"KG\"),((Q#{r}+Y#{r}*R#{r}*AG#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r}),IF(AND(R#{r}<>\"\",S#{r}<>\"\",L#{r}=\"L\"),((Q#{r}+Y#{r}*R#{r}/AG#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r}),\"-\"))))))",
      format: '$###,###.00'
    }
  end

  def quote_currency_unit_column(_q, row_num)
    r = row_num
    {
      formula:
        "=IF(AND(R#{r}=\"\",S#{r}=\"\"),K#{r}&\"/\"&L#{r},IF(AND(R#{r}<>\"\",S#{r}=\"\"),\"BRL\"&\"/\"&L#{r},IF(AND(R#{r}=\"\",S#{r}<>\"\"),K#{r}&\"/\"&(IF(L#{r}=\"KG\",\"LT\",\"KG\")),\"BRL\"&\"/\"&(IF(L#{r}=\"KG\",\"LT\",\"KG\")))))"
    }
  end

  def quote_last_month_price_column(q, _row_num)
    nil # leave blank!
  end

  def quote_last_month_delta_column(_q, row_num)
    r = row_num
    { formula: "=IFERROR((T#{r}/V#{r})-1,\"-\")", format: '0%' }
  end

  def quote_freight_conditions_column(q, _row_num)
    q.freight_condition_text
  end

  def quote_unit_freight_column(q, _row_num)
    to_money q.unit_freight
  end

  def quote_icms_column(q, _row_num)
    to_percentage q.icms
  end

  def quote_pis_confins_column(q, _row_num)
    to_percentage q.pis_confins
  end

  def quote_ipi_column(q, _row_num)
    q.ipi
  end

  def quote_payment_term_column(q, _row_num)
    q.payment_term
  end

  def quote_payment_term_description_column(q, _row_num)
    q.read_attribute(:payment_term_description)
  end

  def quote_encargos_column(_q, row_num)
    r = row_num
    {
      formula:
        "=IF(AC#{r}=\"\",\"-\",IFERROR((1+IF(AC#{r}<=30,2%,IF(AC#{r}<=60,2.5%,3.5%)))^(AC#{r}/30)-1,0))",
      format: '0%'
    }
  end

  def cost_suggested_markup_column(q, _row_num)
    to_percentage q.cost.suggested_markup
  end

  def markup_table_value_column(q, _row_num)
    to_percentage q.optimal_markup&.table_value
  end

  def product_density_column(q, _row_num)
    q.product.density.round(4)
  end

  def quote_observation_column(q, _row_num)
    nil # leave blank!
  end

  def quote_current_column(q, _row_num)
    if q.watched
      q.current
    else
      'Não Monitorada'
    end
  end

  def quote_city_column(q, _row_num)
    q.destination_city_full_name
  end

  def quote_freight_type_column(q, _row_num)
    [q.freight_base_type_text.to_s, q.freight_subtype_text.to_s].join(' - ')
  end

  def quote_vehicle_column(q, _row_num)
    q.vehicle&.name
  end

  def customer_city_column(q, _row_num)
    q.customer&.city&.name
  end

  def freight_plus_taxes_column(_q, row_num)
    r = row_num
    {
        formula:
          "=IF(AND(R#{r}=\"\",S#{r}=\"\"),((Y#{r}/(1-Z#{r}-AA#{r}))*(1+AE#{r})),IF(AND(R#{r}<>\"\",S#{r}=\"\"),(((Y#{r}*R#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r})),IF(AND(R#{r}=\"\",S#{r}<>\"\",L#{r}=\"KG\"),(((Y#{r}*AG#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r})),IF(AND(R#{r}=\"\",S#{r}<>\"\",L#{r}=\"L\"),(((Y#{r}/AG#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r})),IF(AND(R#{r}<>\"\",S#{r}<>\"\",L#{r}=\"KG\"),(((Y#{r}*R#{r}*AG#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r})),IF(AND(R#{r}<>\"\",S#{r}<>\"\",L#{r}=\"L\"),(((Y#{r}*R#{r}/AG#{r})/(1-Z#{r}-AA#{r}))*(1+AE#{r})),\"-\"))))))",
        format: '$###,###.00'
    }
  end

  def quote_fob_final_price_column(_q, row_num)
    r = row_num
    {
        formula: "=T#{r}-AN#{r}",
        format: '$###,###.00'
    }
  end

  def quote_code_if_watched_column(q, _row_num)
    q.code_if_watched
  end

  # query helpers

  def packaging_hash
    @packaging_hash ||= Packaging.pluck(:code, :name).to_h
  end
end
