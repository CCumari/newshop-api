# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create Categories
electronics = Category.find_or_create_by!(name: "Electronics") do |c|
  c.description = "Electronic devices and gadgets"
end

clothing = Category.find_or_create_by!(name: "Clothing") do |c|
  c.description = "Apparel and fashion items"
end

books = Category.find_or_create_by!(name: "Books") do |c|
  c.description = "Books and educational materials"
end

# Create Products
laptop = Product.find_or_create_by!(name: "MacBook Pro") do |p|
  p.price = 199999  # $1999.99 in cents
  p.description = "Powerful laptop for professionals"
  p.stock_quantity = 10
  p.sku = "LAPTOP-001"
  p.category = electronics
end

tshirt = Product.find_or_create_by!(name: "Cotton T-Shirt") do |p|
  p.price = 1999  # $19.99 in cents
  p.description = "Comfortable cotton t-shirt"
  p.stock_quantity = 50
  p.sku = "TSHIRT-001"
  p.category = clothing
end

novel = Product.find_or_create_by!(name: "The Great Gatsby") do |p|
  p.price = 1299  # $12.99 in cents
  p.description = "Classic American literature"
  p.stock_quantity = 25
  p.sku = "BOOK-001"
  p.category = books
end

# Update existing products
existing_tshirt = Product.find_by(name: "T-shirt")
if existing_tshirt
  existing_tshirt.update!(
    price: 1500,
    description: "Basic t-shirt",
    stock_quantity: 20,
    sku: "TSHIRT-BASIC",
    category: clothing
  )
end

existing_hat = Product.find_by(name: "Hat")
if existing_hat
  existing_hat.update!(
    price: 700,
    description: "Stylish hat",
    stock_quantity: 15,
    sku: "HAT-001",
    category: clothing
  )
end

# Create Product Variants
if laptop.persisted?
  # Laptop variants for different configurations
  laptop.product_variants.find_or_create_by!(name: "Storage", value: "512GB") do |v|
    v.price_modifier = 0
    v.stock_quantity = 5
  end

  laptop.product_variants.find_or_create_by!(name: "Storage", value: "1TB") do |v|
    v.price_modifier = 20000  # $200 extra
    v.stock_quantity = 3
  end

  laptop.product_variants.find_or_create_by!(name: "Memory", value: "16GB") do |v|
    v.price_modifier = 0
    v.stock_quantity = 8
  end

  laptop.product_variants.find_or_create_by!(name: "Memory", value: "32GB") do |v|
    v.price_modifier = 40000  # $400 extra
    v.stock_quantity = 2
  end
end

if tshirt.persisted?
  # T-shirt variants for different sizes and colors
  %w[XS S M L XL].each do |size|
    tshirt.product_variants.find_or_create_by!(name: "Size", value: size) do |v|
      v.price_modifier = 0
      v.stock_quantity = 10
    end
  end

  %w[Red Blue Black White].each do |color|
    tshirt.product_variants.find_or_create_by!(name: "Color", value: color) do |v|
      v.price_modifier = 0
      v.stock_quantity = 15
    end
  end
end

puts "Seeded #{Category.count} categories"
puts "Seeded #{Product.count} products"
puts "Seeded #{ProductVariant.count} product variants"
