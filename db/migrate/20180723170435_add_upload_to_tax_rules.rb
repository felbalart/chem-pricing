class AddUploadToTaxRules < ActiveRecord::Migration[5.1]
  def change
    add_reference :tax_rules, :upload, index: true
  end
end
