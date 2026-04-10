Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "flights#index"
  post "flights/search", to: "flights#search", as: :search_flights
  get "flights/:flight_number/:departure_date", to: "flights#show", as: :flight,
      constraints: { departure_date: /\d{4}-\d{2}-\d{2}/ }
end
