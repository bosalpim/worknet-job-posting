class UserPushAlertQueue < ApplicationRecord
  enum status: {
    pending: 'pending',
    processing: 'processing',
    done: 'done'
  }

  belongs_to :user
  belongs_to :alert

  attribute :user_data, :json
end
