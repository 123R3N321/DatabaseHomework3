class Passenger < ApplicationRecord
  self.table_name = "passenger"
  self.primary_key = "pid"

  has_many :bookings, foreign_key: :pid, inverse_of: :passenger, dependent: :restrict_with_exception
end
