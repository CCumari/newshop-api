class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :payments, dependent: :destroy
  has_many :refunds, dependent: :destroy

  validates :status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  enum :status, {
    pending: 'pending',
    payment_pending: 'payment_pending',
    confirmed: 'confirmed',
    processing: 'processing',
    shipped: 'shipped',
    delivered: 'delivered',
    cancelled: 'cancelled',
    refunded: 'refunded'
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :paid, -> { where(status: ['confirmed', 'processing', 'shipped', 'delivered']) }

  def can_be_cancelled?
    pending? || payment_pending? || confirmed?
  end

  def can_be_refunded?
    paid_payment = payments.successful.first
    paid_payment&.can_be_refunded?
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

  def primary_payment
    payments.successful.first
  end

  def total_refunded
    refunds.successful.sum(:amount)
  end

  def refundable_amount
    primary_payment&.refundable_amount || 0
  end

  def payment_status
    return 'unpaid' if payments.empty?
    return 'paid' if payments.successful.any?
    return 'failed' if payments.failed.any?
    'pending'
  end
end
