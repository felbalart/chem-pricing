class FreightService < PowerTypes::Service.new(:q)

  def run
    if @q.freight_condition.fob?
      @q.unit_freight = 0
      return
    end
    splited_subtype = @q.freight_subtype.split '_'
    @subtype = splited_subtype.first
    @op_id = splited_subtype.last if splited_subtype.length > 1
    run_freight_by_type @q.freight_base_type, @subtype
    unless @freight
      error('Problema encontrado calculando o frete')
      return 1
    end

    convert_unit
    convert_currency
    @q.unit_freight = @freight.round(4)
  end

  private

  def freight_original_unit
    if @q.freight_base_type.bulk? && (@subtype == 'normal' || @subtype.to_s.starts_with?('chopped'))
      'lt'
    else
      'kg'
    end
  end

  def convert_unit
    from = freight_original_unit
    to = @q.unit
    @freight *= ConversorUtils.unit_factor(from, to, @q.product.density)
  end

  def convert_currency
    if @q.product && @q.dist_center
      error("Não for encontrada para o produto/CD selecionado", :cost) unless @q.cost
    end
    # DEPRECATED: Now uses ConversorUtils
    #@freight /= @q.brl_usd if @q.currency.usd?
    #@freight /= @q.brl_eur if @q.currency.eur?
    currency_factor = ConversorUtils.currency_factor(:BRL, @q.currency, @q.brl_usd, @q.brl_eur)
    @freight *= currency_factor
  end

  def run_freight_by_type(type, subtype)
    if @subtype!=nil
      send("#{type}_#{subtype[/([a-z]+)/]}") 
      else
        error('Subtipo frete fica vacio')
    end
  end

  def bulk_chopped
    freight_obj = ChoppedBulkFreight.find(@op_id)
    # TODO handle obj not found with error instead of just find!
    amount = freight_obj.amount
    @freight = amount * 0.001
  end

  def bulk_product
    freight_obj = ProductBulkFreight.where(origin: @q.dist_center.city.code, destination: @q.destination_itinerary, vehicle: @q.vehicle, product: @q.product).last
    # if freight_obj.nil?
    #   freight_obj = NormalBulkFreight.where(origin: @q.dist_center.city.code, destination: @q.destination_itinerary , vehicle: @q.vehicle).last
    # end
    if freight_obj.nil?
      return error('Frete Granel - Produto não foi encontrado pelo origem/destino/veiculo/produto dado')
    end
    process_bulk(freight_obj)
  end

  def bulk_normal
    freight_obj = NormalBulkFreight.where(origin: @q.dist_center.city.code, destination: @q.destination_itinerary , vehicle: @q.vehicle).last
    if freight_obj.nil?
      return error('Frete Granel - Normal não foi encontrado pelo origem/destino/veiculo dado')
    end
    process_bulk(freight_obj)
  end

  def process_bulk(freight_obj)
    amount = freight_obj.amount
    toll = freight_obj.toll
    vehicle = freight_obj.vehicle
    capacity = vehicle.capacity
    weight = @q.quantity_kgs
    volume = @q.quantity_lts
    quantity = if freight_obj.class.name == 'ProductBulkFreight'
                 weight
               elsif freight_obj.class.name == 'NormalBulkFreight'
                 volume
               else
                 raise("Wrong Bulk Freight Class #{freight_obj.class.name}")
               end
    # @freight = (((amount / 1000) * (quantity)) + (toll * quantity/1000)) / quantity
    @freight = ((amount + toll) * capacity) / quantity
  end

  def special_calc
    freight_obj = EspecialPackedFreight.where(subtype: @q.freight_subtype, origin: @q.dist_center.city.code, destination: @q.destination_itinerary , vehicle: @q.vehicle).last
    unless freight_obj
      return error("Frete Especial não foi encontrado pelo subtipo/origem/destino/veiculo dado")
    end
    amount = freight_obj.amount
    weight = @q.quantity_kgs

    @freight = (amount) / weight
  end

  def special_chemical
    special_calc
  end

  def special_pharma
    special_calc
  end

  def special_cosmetic
    special_calc
  end

  def packed_pharma
    packed_normal_calc
  end

  def packed_chemical
    packed_normal_calc
  end

  def packed_normal
    packed_normal_calc
  end

  def packed_cosmetic
    packed_normal_calc
  end

  def packed_normal_calc
    freight_obj = NormalPackedFreight.where(origin: @q.dist_center.city.code, destination: @q.destination_itinerary , category: @subtype).last
    unless freight_obj
      return error('Frete Embalado Normal não foi encontrado pelo origem/destino/tipo dado')
    end
    amount = freight_obj.amount
    insurance = freight_obj.insurance
    gris = freight_obj.gris
    toll = freight_obj.toll
    ct_e = freight_obj.ct_e
    minimum = freight_obj.min
    weight = @q.quantity_kgs
    unless @q.cost
      return error('Não foi possível obter preço piso')
    end

    base_price = @q.cost.base_price/@q.cost.amount_for_price
    total_freight = ((amount / 1000) * weight) + (gris * base_price * weight) + (insurance * base_price * weight) + (weight / 100 * toll).ceil + ct_e
    total_freight = minimum if total_freight < minimum
    @freight = total_freight / weight
  end

  def error(msg, attr = :base)
    @q.errors.add(attr, msg)
  end
end
