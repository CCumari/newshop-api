class Refund < ApplicationRecord
  belongs_to :payment
  belongs_to :order

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :reason, presence: true

  enum :status, {
    pending: 'pending',
    succeeded: 'succeeded',
    failed: 'failed',
    cancelled: 'cancelled'
  }

  scope :successful, -> { where(status: 'succeeded') }
  scope :failed, -> { where(status: 'failed') }

  validate :amount_not_greater_than_refundable

  before_validation :set_order_from_payment, if: -> { payment.present? && order.blank? }

  def refund_percentage
    return 0 if payment.amount.zero?
    (amount / payment.amount * 100).round(2)
  end

  def partial_refund?
    amount < payment.amount
  end

  private

  def amount_not_greater_than_refundable
    return unless payment && amount

    if amount > payment.refundable_amount
      errors.add(:amount, "cannot be greater than refundable amount (#{payment.refundable_amount})")
    end
  end

  def set_order_from_payment
    self.order = payment.order
  end
end
