class NoneLtcServiceRequestsConsultingRemind < ApplicationRecord
  scope :before_end_of_today, -> { where('date < ?', (DateTime.now.end_of_day + 9.hours)) }
end
