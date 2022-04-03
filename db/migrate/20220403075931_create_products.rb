class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products, id: false do |t|
      t.integer :id, primary_key: true
      t.integer :owner_id, null: false
      t.string :name, null: false
      t.integer :stock_amount, default: 0, null: false
      t.decimal :pd_price, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
