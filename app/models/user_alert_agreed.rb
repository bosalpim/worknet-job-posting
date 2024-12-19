class UserAlertAgreed < ApplicationRecord
  self.table_name = 'user_alert_agreed'
  belongs_to :alert
  belongs_to :user
end