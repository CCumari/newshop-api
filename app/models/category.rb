class Category < ApplicationRecord
  has_many :products, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  scope :with_products, -> { joins(:products).distinct }
end
