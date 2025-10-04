class CarsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @cars = Car.all
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

  private

  def car_params
    params.require(:car).permit(:title, :brand, :model, :year, :seats, :price_per_day, :address, :photo)
  end

end
