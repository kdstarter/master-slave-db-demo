class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders, id: false do |t|
      t.integer :id, primary_key: true
      t.integer :user_id, null: false
      t.integer :product_id, null: false
      t.integer :pd_amount, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.integer :status, limit: 1, default: 0

      t.timestamps
    end
  end
end
