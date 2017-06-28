require 'csv'

csv_text = File.read(Rails.root.join('db', 'countries.csv'))
csv = CSV.parse(csv_text, headers: true, encoding: 'UTF-8')
csv.each do |row|
  country = Country.find_or_create_by(code: row[1], name: row[0])
  #puts "#{country.name}, #{country.code} saved"
end

csv_text = File.read(Rails.root.join('db', 'cities.csv'))
csv = CSV.parse(csv_text, headers: true, encoding: 'UTF-8')
csv.each do |row|
  city = City.find_or_create_by(code: row[1], name: row[0])
  #puts "#{city.name}, #{city.code} saved"
end

csv_text = File.read(Rails.root.join('db', 'products.csv'))
csv = CSV.parse(csv_text, headers: true, encoding: 'UTF-8')
csv.each do |row|
  product = Product.find_or_create_by(ncm: row[7], origin: row[6], resolution13: row[5], density: row[4],ipi: row[3], unit: row[2],name: row[1], sku: row[0])
  #puts "#{product.name}, #{product.sku} saved"
end

csv_text = File.read(Rails.root.join('db', 'costs.csv'))
csv = CSV.parse(csv_text, headers: true, encoding: 'UTF-8')
csv.each do |row|
  cost = Cost.find_or_create_by(frac_emb: row[16], on_demand: row[15], commentary: row[14], competition_adjustment: row[13],source_adjustment: row[12], min_order_quantity: row[11], lead_time: row[10],product_analyst: row[9], last_month_fob_net: row[8], last_month_base_price: row[7], updated_cost: row[6],amount_for_price: row[5], suggested_markup: row[4],base_price: row[3], currency: row[2],dist_center_id: row[1], product_id: row[0])
  puts "#{cost.currency}"
end

{ pis_confins: 0.04, interest_2_30: 0.01, interest_31_60: 0.02, interest_more_60: 0.03 }.each do |name, value|
  sys_var = SystemVariable.find_or_create_by(name: name)
  sys_var.update(value: value) if sys_var.value.nil?
end