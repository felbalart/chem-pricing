class AddOldCodeToCities < ActiveRecord::Migration[5.1]
  def change
    add_column :cities, :old_code, :string
  end
end
