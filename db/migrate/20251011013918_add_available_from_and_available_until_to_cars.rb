class AddAvailableFromAndAvailableUntilToCars < ActiveRecord::Migration[7.1]
  def change
    add_column :cars, :available_from, :date
    add_column :cars, :available_until, :date
  end
end
