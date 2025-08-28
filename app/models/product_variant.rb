class ProductVariant < ApplicationRecord
  belongs_to :product

  validates :name, presence: true
  validates :value, presence: true
  validates :price_modifier, presence: true, numericality: true
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def final_price
    product.price + price_modifier
  end

  def in_stock?
    stock_quantity > 0
  end
end
