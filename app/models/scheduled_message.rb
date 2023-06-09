class ScheduledMessage < ApplicationRecord
  def sendable
    return User.receive_notifications.where(phone_number: phone_number).length > 0
  end
end
