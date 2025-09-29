class CarsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @cars = Car.all
  end

  def show
    # this would show detail of a car
    @car = Car.find(params[:id])
    @cars = @car.bookings
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

  private

  def car_params
    params.require(:car).permit(:title, :brand, :model, :year, :seats, :price_per_day, :address)
  end

end
