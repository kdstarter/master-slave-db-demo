class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: false do |t|
      t.integer :id, primary_key: true
      t.string :name, limit: 32, null: false
      t.decimal :credit, precision: 12, scale: 2, default: 0, null: false

      t.timestamps
    end
  end
end
