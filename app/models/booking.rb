class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :car

  validates :start_date, :end_date, :total_price, presence: true
  validates :status, inclusion: { in: %w[pending accepted declined cancelled] }
end
