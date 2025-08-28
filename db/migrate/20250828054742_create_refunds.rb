class CreateRefunds < ActiveRecord::Migration[8.0]
  def change
    create_table :refunds do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.string :stripe_refund_id
      t.text :reason

      t.timestamps
    end
  end
end
