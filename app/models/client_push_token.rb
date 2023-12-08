class ClientPushToken < ApplicationRecord
  belongs_to :client

  before_save :update_last_activated_at
  scope :valid, -> { where(is_accept_notification: true, last_activated_at: 2.month.ago...) }

  private

  def update_last_activated_at
    self.last_activated_at = DateTime.now
  end
end
