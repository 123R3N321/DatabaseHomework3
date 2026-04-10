class Flight < ApplicationRecord
  self.table_name = "flight"

  belongs_to :flight_service, foreign_key: :flight_number, primary_key: :flight_number, inverse_of: :flights
  belongs_to :aircraft, foreign_key: :plane_type, primary_key: :plane_type, inverse_of: :flights

  # Composite natural key; use find_by(flight_number:, departure_date:)

  def self.search(origin:, destination:, start_date:, end_date:)
    o = origin.to_s.upcase.strip
    d = destination.to_s.upcase.strip
    joins(:flight_service)
      .merge(FlightService.where(origin_code: o, dest_code: d))
      .where(departure_date: start_date..end_date)
      .includes(:flight_service, :aircraft)
      .order(:departure_date, :flight_number)
  end

  def booked_seats_count
    Booking.where(flight_number: flight_number, departure_date: departure_date).count
  end

  def available_seats
    cap = aircraft.capacity
    [cap - booked_seats_count, 0].max
  end
end
