class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :car

  validates :start_date, :end_date, :total_price, presence: true
  validates :status, inclusion: { in: %w[pending accepted declined cancelled] }
  validate :no_date_conflicts, on: :update, if: :should_check_conflicts?

  private

  def should_check_conflicts?
    dates_changed? || becoming_accepted?
  end

  def dates_changed?
    start_date_changed? || end_date_changed?
  end

  def becoming_accepted?
    status_changed? && status == 'accepted'
  end

  def no_date_conflicts
    return if car.nil? || start_date.nil? || end_date.nil?

    overlapping = car.bookings
      .where.not(id: id)
      .where(status: ['pending', 'accepted'])
      .where("start_date <= ? AND end_date >= ?", end_date, start_date)

    if overlapping.exists?
      if becoming_accepted?
        errors.add(:base, "You have already accepted a booking for these dates for this car.")
      else
        errors.add(:base, "This car is not available on those dates. Please choose different dates.")
      end
    end
  end
end
