class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total_amount
    cart_items.sum { |item| item.product.price * item.quantity }
  end

  def total_items
    cart_items.sum(:quantity)
  end

  def empty?
    cart_items.empty?
  end

  def clear!
    cart_items.destroy_all
  end
end
