class AddSubtypeToEspecialPackedFreights < ActiveRecord::Migration[5.1]
  def change
    add_column :especial_packed_freights, :subtype, :string
  end
end
