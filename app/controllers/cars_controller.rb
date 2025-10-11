class CarsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_car,            only: %i[show edit update destroy]
  before_action :authorize_owner!,   only: %i[edit update destroy]

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

  def edit
    # Solo renderiza el form. @car ya viene de set_car
  end

  def update
    # 1) @car ya está seteado por set_car
    # 2) Intentamos actualizar con los params permitidos
    if @car.update(car_params)
      # 3) Éxito: redirige al show con aviso
      redirect_to @car, notice: "Car updated successfully."
    else
      # 4) Falla de validación: volvemos al form edit mostrando errores
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def authorize_owner!
    redirect_to cars_path, alert: "Not authorized." unless @car.user == current_user
  end

  def car_params
    params.require(:car).permit(:title, :brand, :model, :year, :seats, :price_per_day, :address, :photo, :available_from, :available_until)
  end

end
