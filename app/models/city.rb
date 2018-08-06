class City < ApplicationRecord


  validates_presence_of :name, :code

  def full_name
    [name, state].join(' - ')
  end

  def state
    code[0..1] if code
  end

  def self.xls_mode
    :update
  end

  def self.xls_fields
    {
      name: :attr,
      code: :key,
    }
  end
end

# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  name       :string
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  upload_id  :integer
#  old_code   :string
#
# Indexes
#
#  index_cities_on_code       (code)
#  index_cities_on_upload_id  (upload_id)
#
