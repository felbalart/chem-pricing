class Customer < ApplicationRecord
  has_many :optimal_markups
  has_many :quotes
end

# == Schema Information
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
