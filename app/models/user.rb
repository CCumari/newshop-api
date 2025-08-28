class User < ApplicationRecord
  has_secure_password

  has_many :carts, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlisted_products, through: :wishlist_items, source: :product
  has_many :orders, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true

  before_create :generate_confirmation_token

  def confirm!
    update(confirmed_at: Time.current, confirmation_token: nil)
  end

  def confirmed?
    confirmed_at.present?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def current_cart
    carts.first_or_create
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
  end
end
