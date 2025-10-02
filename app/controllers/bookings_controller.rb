class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_car,     only: %i[new create]
  before_action :set_booking, only: %i[update destroy]
  def index
    @my_bookings = current_user.bookings.includes(:car)
    @incoming_bookings = Booking.joins(:car)
      .where(cars: { user_id: current_user.id })
      .where.not(status: "cancelled")
      .includes(:user, :car)
  end

  def new
    @booking = @car.bookings.new
  end

  def create
    @car = Car.find(params[:car_id])
    if @car.user == current_user
      redirect_to cars_path, alert: "You cannot book your own car." and return
    end
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
      if @booking.status == "cancelled"
        redirect_to bookings_path, notice: "Booking was cancelled. The renter has been notified."
        # Optionally, send an email or notification to the renter here
      else
        redirect_to bookings_path, notice: "Booking updated."
      end
    else
      redirect_to bookings_path, alert: @booking.errors.full_messages.to_sentence
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    if @booking.user == current_user
      @booking.destroy
      redirect_to bookings_path, notice: "Booking deleted."
    else
      redirect_to bookings_path, alert: "Not authorized."
    end
  end

  private

  def set_car
    @car = Car.find(params[:car_id])
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date)
  end

  def status_params
    params.require(:booking).permit(:status)
  end

  def active_booking
    @active_booking = @car.bookings.where.not(status: ["cancelled", "declined"]).where("end_date >= ?", Date.today).first
  end
end
