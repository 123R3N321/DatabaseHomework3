class Booking < ApplicationRecord
  self.table_name = "booking"

  belongs_to :passenger, foreign_key: :pid, inverse_of: :bookings
end
