class AddOldCodeToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :old_code, :string
  end
end
