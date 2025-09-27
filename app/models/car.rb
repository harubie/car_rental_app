class Car < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :destroy

  validates :title, :brand, :model, :year, :seats, :price_per_day, :address, presence: true
end
