class Alert < ApplicationRecord
  has_many :user_alert_agreed
  has_many :users, through: :user_alert_agreed
  has_many :user_push_alert_queues, dependent: :destroy
end