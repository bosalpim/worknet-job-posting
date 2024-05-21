class NoneLtcServiceRequest < ApplicationRecord
  scope :before_end_of_today, -> { where('created_at < ?', DateTime.now.end_of_day) }

  enum status: {
    before_consulting: "before_consulting",
    consulting: "consulting",
    recruiting: "recruiting",
    service_start_ready: "service_start_ready",
    service_in_progress: "service_in_progress",
    service_terminated: "service_terminated",
    consulting_canceled: "consulting_canceled",
    waiting: "waiting"
  }
end
