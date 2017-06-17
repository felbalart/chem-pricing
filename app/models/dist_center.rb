class DistCenter < ApplicationRecord
  has_many :costs
  has_many :optimal_markups
  has_many :sales
  belongs_to :city
end

# == Schema Information
#
# Table name: dist_centers
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city_id    :integer
#
# Indexes
#
#  index_dist_centers_on_city_id  (city_id)
#
