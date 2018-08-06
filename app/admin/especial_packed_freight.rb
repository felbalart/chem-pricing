ActiveAdmin.register EspecialPackedFreight do
  menu parent: '4. Logistica'
  permit_params :subtype, :origin, :destination, :vehicle_id, :amount
  actions :all

  index do
    column(:subtype) { |r| r.subtype&.text }
    column :origin
    column :destination
    column("Tp Veic") { |r| r.vehicle.name }
    column :amount
    actions
  end

  form do |f|
    f.inputs "Frete Especial" do
      f.input :subtype, as: :select, collection: EspecialPackedFreight.subtype.options
      f.input :origin
      f.input :destination
      f.input :vehicle
      f.input :amount
    end
    f.actions
  end
  csv do
    build_csv_columns(:especial_packed_freight).each do |k, v|
      column(k, humanize_name: false, &v)
    end
  end

  action_item :upload do
    link_to 'Upload Tabela', new_upload_path(model: :especial_packed_freight)
  end

end