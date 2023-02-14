class BusinessClient < ApplicationRecord
  belongs_to :business
  belongs_to :client
end
