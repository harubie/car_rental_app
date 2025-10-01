class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_car,     only: %i[new create]
  before_action :set_booking, only: %i[update]
  def index
    @my_bookings = current_user.bookings.includes(:car)  # as a renter
    @incoming_bookings = Booking.joins(:car).where(cars: { user_id: current_user.id }).includes(:user, :car)  # as a car owner
  end

  def new
    @booking = @car.bookings.new
  end

  def create
    @car = Car.find(params[:car_id])
    @booking = @car.bookings.new(booking_params)
    @booking.user   = current_user
    @booking.status = "pending"

    if @booking.start_date.present? && @booking.end_date.present?
      days = (@booking.end_date - @booking.start_date).to_i
      @booking.total_price = days.positive? ? days * @car.price_per_day : 0
    end

    if @booking.save
      redirect_to bookings_path, notice: "Booking requested."
      else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    unless @booking.car.user == current_user
      redirect_to bookings_path, alert: "Not authorized." and return
    end
    if @booking.update(booking_params)
      redirect_to bookings_path, notice: "Booking updated."
    else
      redirect_to bookings_path, alert: @booking.errors.full_messages.to_sentence
    end
  end

  def destroy
    @booking = current_user.bookings.find(params[:id])
    @booking.destroy
    redirect_to bookings_path, notice: "Booking deleted successfully!"
  end

  private

  def set_car
    @car = Car.find(params[:car_id])
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date, :status)
  end
end
