class FlightService < ApplicationRecord
  self.table_name = "flightservice"
  self.primary_key = "flight_number"

  has_many :flights, foreign_key: :flight_number, inverse_of: :flight_service, dependent: :restrict_with_exception
end
