ActiveAdmin.register Customer do
  menu parent: '6. Companhia'
  permit_params :code, :name, :email, :city_id, :cnpj, :contact, :country_id, :old_code
  actions :all

  index do
    column :name
    column :code
    column :cnpj
    column :country
    column("Estado") { |r| r.city.try :state }
    column :city
    column :contact
    column :email
    column :old_code
    actions
  end


  filter :name
  filter :code
  filter :cnpj
  filter :country
  filter :state
  filter :city
  filter :old_code

  csv do
    build_csv_columns(:customer).each do |k, v|
      column(k, humanize_name: false, &v)
    end
  end

  action_item :upload do
    link_to 'Upload Tabela', new_upload_path(model: :customer)
  end


end


