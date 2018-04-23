class SimulatorService < PowerTypes::Service.new(:q)

  def run
    calc_taxes
    base_price = calc_base_price
    # DEPRECATED freight conversion now done on freight service
    # unit_freight = calc_unit_freight
    financial_cost = @q.financial_cost

    if @q.fixed_price
      @q.markup = (((((@q.unit_price * @q.tax_discount)/(1.0 + financial_cost)) - @q.unit_freight ) / base_price) - 1.0).round(3)
      # @q.fob_net_price = (base_price * (1.0 + @q.markup)).round(3)
      @q.fob_net_price = @q.unit_price - @q.taxed_charged_freight
    else
      @q.unit_price = ((((base_price * (1.0 + @q.markup) + @q.unit_freight))/@q.tax_discount) * (1.0 + financial_cost)).round(3)
      # @q.fob_net_price = (base_price * (1.0 + @q.markup)).round(3)
      @q.fob_net_price = (((base_price * (1.0 + @q.markup)) / @q.tax_discount) * (1.0 + financial_cost)).round(3)
    end


    aux_print = {
        U_PRICE: @q.unit_price&.to_f,
        MKUP: @q.markup&.to_f,
        COST: base_price&.to_f,
        U_FREIGHT: @q.unit_freight&.to_f,
        T_1_ICMS_PC: @q.tax_discount&.to_f,
        PRAZO: financial_cost&.to_f,
        QCURRENCY: @q.currency,
        CST_CURRENCY: @q.cost.currency
    }

    # puts "QUOTE SIMULATION OUTPUT"
    # pp aux_print
    # puts "#{@q.numb}cost;#{aux_print[:COST]}"
    # puts "#{@q.numb}freight;#{aux_print[:U_FREIGHT_CONV]}"
    #puts "#{@q.numb}imp;#{aux_print[:T_1_ICMS_PC]}"
    # puts @q.markup&.to_f
    #puts unit_freight.to_f
  end

  def calc_taxes
    if @q.icms_padrao && @q.product.resolution13 && @q.origin_state != @q.destination_state
      @q.icms = 0.04
    elsif @q.icms_padrao
      icms_destination_state = @q.customer&.city&.state || @q.city&.state
      raise "No ICMS destination" unless icms_destination_state
      @q.icms = IcmsTax.tax_value_for(@q.origin_state, icms_destination_state)
      error("Não encontrado para esta origem/destino", :icms) if @q.icms.nil?
    end

    @q.ipi = @q.product.ipi

    if @q.pis_confins_padrao
      # TODO QM validate presence when not padrao.
      # TODO Handle Sys Var Unset
      @q.pis_confins = SystemVariable.get :pis_confins
    end
    # 1 - @q.icms - @q.pis_confins
    @q.tax_discount # use new method better
  end

  def calc_base_price
    c_conversor = currency_conversor(@q.cost.currency, @q.currency)
    u_conversor = unit_conversor(@q.product.unit, @q.unit)
    @q.cost.base_price * c_conversor * u_conversor / @q.cost.amount_for_price
  end

  # DEPRECATED 2018-03-28 freight comes converted from freight service
  # def calc_unit_freight
  #   return @q.unit_freight unless @q.freight_padrao
  #   @q.unit_freight * currency_conversor('brl', @q.currency)
  #
  #
  #   if @q.freight_padrao
  #     c_conversor = currency_conversor('brl', @q.currency)
  #   else
  #     c_conversor = 1
  #   end
  #   u_conversor = unit_conversor(@q.product.unit, @q.unit) #freight service gives amount based on product's unit
  #   @q.unit_freight * c_conversor * u_conversor
  # end

  def currency_conversor(from, to)
    case [from, to]
    when ['brl', 'usd']
      1.0 / @q.brl_usd
    when ['brl', 'eur']
      1.0 / @q.brl_eur
    when ['usd', 'brl']
      @q.brl_usd
    when ['usd', 'eur']
      @q.brl_usd / @q.brl_eur
    when ['eur', 'brl']
      @q.brl_eur
    when ['eur', 'usd']
      @q.brl_eur / @q.brl_usd
    else
      1.0
    end
  end

  def unit_conversor(from, to)
    return 1.0 if from == to
    if from == 'lt' # to == kg
      1.0 / @q.product.density
    else # from == kg && to == lt
      @q.product.density
    end
  end

  def setup_cost_and_markup
    @q.cost = Cost.where(product: @q.product, dist_center: @q.dist_center).last
    @q.optimal_markup = OptimalMarkup.where(product: @q.product, dist_center: @q.dist_center, customer: @q.customer).last
    @q.optimal_markup ||= OptimalMarkup.where(product: @q.product, dist_center: @q.dist_center, customer_id: nil).last
    if @q.product && @q.dist_center
      error("Não for encontrada para o produto/CD selecionado", :cost) unless @q.cost
      error("não for encontrada para o produto/CD selecionado", :optimal_markup) unless @q.optimal_markup
    end
  end

  def error(msg, attr = :base)
    @q.errors.add(attr, msg)
  end
end
