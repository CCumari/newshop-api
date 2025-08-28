class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.decimal :total_amount
      t.text :shipping_address
      t.text :billing_address

      t.timestamps
    end
  end
end
