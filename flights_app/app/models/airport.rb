class Airport < ApplicationRecord
  self.table_name = "airport"
  self.primary_key = "airport_code"
end
