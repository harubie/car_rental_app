class CreateCars < ActiveRecord::Migration[7.1]
  def change
    create_table :cars do |t|
      t.string :title
      t.string :brand
      t.string :model
      t.integer :year
      t.integer :seats
      t.integer :price_per_day
      t.text :description
      t.string :address
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
