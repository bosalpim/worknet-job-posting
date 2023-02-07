class KakaoNotificationResult < ApplicationRecord
  validates :send_type, presence: true
  validates :template_id, presence: true
  validates :success_count, numericality: { grater_than_or_equal_to: 0 }
  validates :fail_count, numericality: { grater_than_or_equal_to: 0 }

  enum send_type: {
    proposal: 'proposal',
    new_job_posting: "new_job_posting",
    personalized_notification: "personalized_notification",
    extra_benefit_notification: "extra_benefit_notification"
  }
end
