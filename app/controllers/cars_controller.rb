class CarsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_car,            only: %i[show edit update destroy]
  before_action :authorize_owner!,   only: %i[edit update destroy]

  def index
    @cars = Car.all
    @markers = @cars.geocoded.map { |car| { lat: car.latitude, lng: car.longitude, id: car.id } }
  end

  def show
    @bookings = @car.bookings
    @booking  = Booking.new
  end

  def new
    @car = Car.new
  end

  def create
    @car = current_user.cars.build(car_params)
    if @car.save
      redirect_to @car, notice: "Your car is now listed!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # solo renderiza
  end

  def update
    if @car.update(car_params)
      redirect_to @car, notice: "Car updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @car.destroy
    redirect_to cars_path, notice: "Car deleted."
  end

  def search
    @cars = Car.all
    @cars = @cars.near(params[:location], 20) if params[:location].present?

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]) rescue nil
      end_date   = Date.parse(params[:end_date])   rescue nil

      if start_date && end_date
        unavailable_car_ids = Booking.where('start_date <= ? AND end_date >= ?', end_date, start_date)
                                     .pluck(:car_id)
        @cars = @cars.where.not(id: unavailable_car_ids)
                     .where("available_from <= ? AND available_until >= ?", start_date, end_date)
      end
    end

    @markers = @cars.geocoded.map { |car| { lat: car.latitude, lng: car.longitude, id: car.id } }
    render :index
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def authorize_owner!
    redirect_to cars_path, alert: "Not authorized." unless @car.user == current_user
  end

  def car_params
    params.require(:car).permit(
      :title, :brand, :model, :year, :seats, :price_per_day,
      :address, :photo, :available_from, :available_until
    )
  end
end
