class User < ApplicationRecord
  has_secure_password

  has_many :carts
  validates :email, presence: true, uniqueness: true

  before_create :generate_confirmation_token

  def confirm!
    update(confirmed_at: Time.current, confirmation_token: nil)
  end

  def confirmed?
    confirmed_at.present?
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
  end
end
