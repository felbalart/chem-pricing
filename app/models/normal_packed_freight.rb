class NormalPackedFreight < ApplicationRecord
	extend Enumerize
<<<<<<< HEAD

	enumerize :category, in: [:pharma, :chemical]
=======
>>>>>>> Minor_changes

end

# == Schema Information
#
# Table name: normal_packed_freights
#
#  id          :integer          not null, primary key
#  origin      :string
#  destination :string
#  category    :string
#  amount      :decimal(, )
#  insurance   :decimal(, )
#  gris        :decimal(, )
#  toll        :decimal(, )
#  ct_e        :decimal(, )
#  min         :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#