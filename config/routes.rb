Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # Root path - browse available cars
  root to: "cars#index"

  # Cars routes
  resources :cars, only: [:index, :show, :new, :create, :destroy] do
    # Nested booking routes - for booking a specific car
    resources :bookings, only: [:new, :create]
  end

  # Independent booking routes - for managing user's bookings
  resources :bookings, only: [:index, :update, :destroy]
end
