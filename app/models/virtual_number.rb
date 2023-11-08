class VirtualNumber < ApplicationRecord
  USAGE_YOBOSA = :yobosa
  USAGE_CENTER = :center

  default_scope { order(:vn) }

  enum usage: {
    yobosa: 'yobosa',
    center: 'center'
  }

  validates :vn, presence: true, uniqueness: true
end
