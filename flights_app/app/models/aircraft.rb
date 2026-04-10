class Aircraft < ApplicationRecord
  self.table_name = "aircraft"
  self.primary_key = "plane_type"

  has_many :flights, foreign_key: :plane_type, inverse_of: :aircraft, dependent: :restrict_with_exception
end
