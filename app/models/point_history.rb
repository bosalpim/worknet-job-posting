class PointHistory < ApplicationRecord
  belongs_to :point_item
  belongs_to :user
end
