class TaxRule < ApplicationRecord
  extend Enumerize
  belongs_to :customer, required: false
  belongs_to :product, required: false
  belongs_to :upload, required: false

  validates_presence_of :tax_type, :value
  validate :pis_confis_blank_cities

  enumerize :tax_type, in: [:icms, :pis_confins]

  scope :icms, -> { where(tax_type: :icms) }
  scope :pis_confins, -> { where(tax_type: :pis_confins) }

  # scope :city_specific, -> { where('LENGTH(origin) > 2 AND LENGTH(destination) > 2') }
  scope :city_dest, -> { where('LENGTH(destination) > 2') }
  scope :city_orig, -> { where('LENGTH(origin) > 2') }
  scope :state_dest, -> { where('LENGTH(destination) = 2') }
  scope :state_orig, -> { where('LENGTH(destination) = 2') }
  scope :nil_dest, -> { where(destination: nil) }
  scope :nil_orig, -> { where(origin: nil) }

  scope :orig_city_match, -> city_code { where(origin: city_code) }
  scope :dest_city_match, -> city_code { where(destination: city_code) }

  scope :orig_state_match, -> state_code { where(origin: state_code) }
  scope :dest_state_match, -> state_code { where(destination: state_code) }

  scope :customer_match, -> customer { where(customer: customer) }
  scope :product_match, -> product { where(product: product) }

  def self.xls_mode
    :create
  end

  def self.xls_fields
    {
        tax_type: :attr,
        'customer.code': :f_key,
        'customer.name': nil,
        'product.sku': :f_key,
        'product.name': nil,
        origin: :attr,
        destination: :attr,
        value: :attr
    }
  end

  def pis_confis_blank_cities
    if tax_type == 'pis_confins' && (origin.present? || destination.present?)
      errors.add(:tax_type, 'Somente imposto ICMS permite especificar origem/destino')
    end
  end

  def <=>(other)
    score <=> other.score
  end

  def score
    sc = 0
    if orig_city?
      sc += 2
    elsif orig_state?
      sc += 1
    end
    if dest_city?
      sc += 2
    elsif dest_state?
      sc += 1
    end
    sc += 2 if customer.present?
    sc += 2 if product.present?
    sc
  end

  def orig_city?
    origin.length > 2 if origin.present?
  end

  def orig_state?
    origin.length == 2 if origin.present?
  end

  def dest_city?
    destination.length > 2 if destination.present?
  end

  def dest_state?
    destination.length == 2 if destination.present?
  end
end

# == Schema Information
#
# Table name: tax_rules
#
#  id          :integer          not null, primary key
#  tax_type    :string
#  customer_id :integer
#  product_id  :integer
#  origin      :string
#  destination :string
#  value       :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  upload_id   :integer
#
# Indexes
#
#  index_tax_rules_on_customer_id  (customer_id)
#  index_tax_rules_on_product_id   (product_id)
#  index_tax_rules_on_upload_id    (upload_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (product_id => products.id)
#
