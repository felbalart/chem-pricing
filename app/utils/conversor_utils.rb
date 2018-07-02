module ConversorUtils
  extend self
  def unit_factor(from_unit, to_unit, density)
    raise 'Unidade a converter não pode estar em branco' if to_unit.blank?
    raise 'Unidade para converter desde: não pode estar em branco' if from_unit.blank?
    from_unit = from_unit.to_s.downcase
    to_unit = to_unit.to_s.downcase
    return 1.0 if from_unit == to_unit
    if from_unit == 'lt' && to_unit == 'kg'
      1.0 / density
    elsif from_unit == 'kg' && to_unit == 'lt'
      density
    else
      raise "Unhandled unit conversion from: #{from_unit} to: #{to_unit}"
    end
  end

  def currency_factor(from_currency, to_currency, brl_usd_rate = nil, brl_eur_rate = nil)
    raise 'Moeda a converter não pode estar em branco' if to_currency.blank?
    raise 'Moeda para converter desde: não pode estar em branco' if from_currency.blank?
    from_currency = from_currency.to_s.downcase
    to_currency = to_currency.to_s.downcase
    return 1.0 if from_currency == to_currency
    brl_usd_rate ||= GetExchangeRate.for(from: :USD, to: :BRL) if from_currency == 'usd' || to_currency == 'usd'
    brl_eur_rate ||= GetExchangeRate.for(from: :EUR, to: :BRL) if from_currency == 'eur' || to_currency == 'eur'

    case [from_currency, to_currency]
      when ['brl', 'usd']
        1.0 / brl_usd_rate
      when ['brl', 'eur']
        1.0 / brl_eur_rate
      when ['usd', 'brl']
        brl_usd_rate
      when ['usd', 'eur']
        brl_usd_rate / brl_eur_rate
      when ['eur', 'brl']
        brl_eur_rate
      when ['eur', 'usd']
        brl_eur_rate / brl_usd_rate
      else
        raise "Unhandled currency conversion from: #{from_currency} to: #{to_currency}"
    end
  end
end