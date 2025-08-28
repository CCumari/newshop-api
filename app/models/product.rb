class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :product_variants, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :users_who_wishlisted, through: :wishlist_items, source: :user

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, uniqueness: true, allow_blank: true

  scope :in_stock, -> { where('stock_quantity > 0') }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  def in_stock?
    stock_quantity > 0
  end

  def display_price
    product_variants.any? ? product_variants.minimum(:price_modifier) + price : price
  end
end
