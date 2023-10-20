class UserPushToken < ApplicationRecord
  belongs_to :user

  scope :vaild_tokens, -> { where(is_accept_notification: true).where('last_activated_at >= ?', 2.month.ago) }
end
