class AddCategoryToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :category, null: true, foreign_key: true
    add_column :products, :description, :text
    add_column :products, :stock_quantity, :integer, default: 0
    add_column :products, :sku, :string
    add_index :products, :sku, unique: true
  end
end
