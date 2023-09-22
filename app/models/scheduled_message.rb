class ScheduledMessage < ApplicationRecord
  def sendable
    return User.receive_job_notifications.where(phone_number: phone_number).length > 0
  end
end
