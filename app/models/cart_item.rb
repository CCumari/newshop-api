class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validate :product_in_stock

  def total_price
    product.price * quantity
  end

  private

  def product_in_stock
    return unless product
    
    if product.stock_quantity < quantity
      errors.add(:quantity, "exceeds available stock (#{product.stock_quantity})")
    end
  end
end
