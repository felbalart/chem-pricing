class NormalBulkFreight < ApplicationRecord
  belongs_to :vehicle
end

# == Schema Information
#
# Table name: normal_bulk_freights
#
#  id          :integer          not null, primary key
#  origin      :string
#  destination :string
#  vehicle_id  :integer
#  amount      :decimal(, )
#  toll        :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_normal_bulk_freights_on_vehicle_id  (vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (vehicle_id => vehicles.id)
#