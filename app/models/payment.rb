class Payment < ApplicationRecord
  belongs_to :order
  has_many :refunds, dependent: :destroy

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :stripe_payment_intent_id, presence: true, uniqueness: true

  enum :status, {
    pending: 'pending',
    requires_payment_method: 'requires_payment_method',
    processing: 'processing',
    succeeded: 'succeeded',
    failed: 'failed',
    cancelled: 'cancelled',
    requires_action: 'requires_action'
  }

  scope :successful, -> { where(status: 'succeeded') }
  scope :failed, -> { where(status: 'failed') }
  
  def refundable_amount
    amount - total_refunded
  end

  def total_refunded
    refunds.successful.sum(:amount)
  end

  def fully_refunded?
    total_refunded >= amount
  end

  def can_be_refunded?
    succeeded? && refundable_amount > 0
  end
end
