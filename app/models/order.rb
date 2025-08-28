class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  enum :status, {
    pending: 'pending',
    confirmed: 'confirmed',
    processing: 'processing',
    shipped: 'shipped',
    delivered: 'delivered',
    cancelled: 'cancelled'
  }

  scope :recent, -> { order(created_at: :desc) }

  def can_be_cancelled?
    pending? || confirmed?
  end

  def total_items
    order_items.sum(:quantity)
  end

  def calculate_total
    order_items.sum { |item| item.price * item.quantity }
  end

  def order_number
    "ORD-#{id.to_s.rjust(6, '0')}"
  end
end
