class EspecialPackedFreight < ApplicationRecord
  extend Enumerize

	belongs_to :vehicle
  belongs_to :upload, required: false
  validates_presence_of :subtype

  enumerize :subtype, in: Quote.freight_subtype_options(:special)

  # removed
  # after_save :update_watched_quotes
  # def update_watched_quotes
  #   WatchedUpdateService.new.run_for_freight_obj(self)
  # end

	def self.xls_mode
    :update
  end

  def self.xls_fields
    {
      subtype: :key,
      origin: :key,
      destination: :key,
      'vehicle.name': :f_key,
      amount: :attr
    }
  end

end

# == Schema Information
#
# Table name: especial_packed_freights
#
#  id          :integer          not null, primary key
#  origin      :string
#  destination :string
#  vehicle_id  :integer
#  amount      :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  upload_id   :integer
#  subtype     :string
#
# Indexes
#
#  index_especial_packed_freights_on_upload_id   (upload_id)
#  index_especial_packed_freights_on_vehicle_id  (vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (vehicle_id => vehicles.id)
#
