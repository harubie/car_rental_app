class CarsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @cars = Car.all

    @markers = @cars.geocoded.map do |car|
      {
        lat: car.latitude,
        lng: car.longitude,
        id: car.id
      }
    end
  end

  def show
    # this would show detail of a car
    @car = Car.find(params[:id])
    @cars = @car.bookings
    @booking = Booking.new
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

  def destroy
    @car = Car.find(params[:id])
    if @car.user == current_user
      @car.destroy
      redirect_to cars_path, notice: "Car deleted."
    else
      redirect_to cars_path, alert: "Not authorized."
    end
  end

  def search
    @cars = Car.all

    if params[:location].present?
    @cars = @cars.near(params[:location], 20)
    end

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      unavailable_car_ids = Booking.where(
        'start_date <= ? AND end_date >= ?',
        end_date, start_date
      ).pluck(:car_id)

      @cars = @cars.where.not(id: unavailable_car_ids)
                   .where("available_from <= ? AND available_until >= ?", start_date, end_date)
    end

      @markers = @cars.geocoded.map do |car|
    {
      lat: car.latitude,
      lng: car.longitude,
      id: car.id
    }
  end

    render :index
  end

  private

  def car_params
    params.require(:car).permit(:title, :brand, :model, :year, :seats, :price_per_day, :address, :photo, :available_from, :available_until)
  end

end
