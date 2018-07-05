class Cost < ApplicationRecord
	extend Enumerize

  belongs_to :product
  belongs_to :dist_center
  belongs_to :upload, required: false
  has_many :quotes

  validates_presence_of :product_id, :dist_center_id, :base_price,
    :currency, :amount_for_price
  validates :base_price, numericality: { greater_than: 0 }

  after_save :update_watched_quotes

  enumerize :currency, in: [:brl, :usd, :eur]
  enumerize :on_demand, in: [:on_request, :discontinued, :regular]

  def update_watched_quotes
    return if upload.present?
    WatchedUpdateJob.perform_later('cost', id)
  end

  def lead_time_order?
    on_demand == 'CONTRA PEDIDO'
  end

def self.xls_mode
    :create
  end

  def self.xls_fields
    {
      'dist_center.code': :f_key,
      'product.sku': :f_key,
      'product.name': nil,
      currency: :attr,
      amount_for_price: :attr,
      base_price: :attr,
      suggested_markup: :attr,
      updated_cost: :attr,
      product_analyst: :attr,
      on_demand: :attr,
      lead_time: :attr,
      min_order_quantity: :attr,
      frac_emb: :attr,
      created_at: :attr
    }
  end
end


# == Schema Information
#
# Table name: costs
#
#  id                     :integer          not null, primary key
#  product_id             :integer
#  dist_center_id         :integer
#  base_price             :decimal(, )
#  currency               :string
#  suggested_markup       :decimal(, )
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  amount_for_price       :decimal(, )
#  updated_cost           :boolean
#  last_month_base_price  :decimal(, )
#  last_month_fob_net     :decimal(, )
#  product_analyst        :string
#  commentary             :string
#  on_demand              :string
#  frac_emb               :boolean
#  source_adjustment      :string
#  competition_adjustment :string
#  lead_time              :string
#  min_order_quantity     :string
#  upload_id              :integer
#
# Indexes
#
#  index_costs_on_dist_center_id  (dist_center_id)
#  index_costs_on_product_id      (product_id)
#  index_costs_on_upload_id       (upload_id)
#
# Foreign Keys
#
#  fk_rails_...  (dist_center_id => dist_centers.id)
#  fk_rails_...  (product_id => products.id)
#
