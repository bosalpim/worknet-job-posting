class KakaoNotificationResult < ApplicationRecord
  PROPOSAL = "proposal".freeze
  NEW_JOB_POSTING = "new_job_posting".freeze
  PERSONALIZED = "personalized_notification".freeze
  EXTRA_BENEFIT = "extra_benefit_notification".freeze

  validates :send_type, presence: true
  validates :template_id, presence: true
  validates :success_count, numericality: { grater_than_or_equal_to: 0 }
  validates :fail_count, numericality: { grater_than_or_equal_to: 0 }

  enum send_type: {
    PROPOSAL => 'proposal',
    NEW_JOB_POSTING => "new_job_posting",
    PERSONALIZED => "personalized_notification",
    EXTRA_BENEFIT => "extra_benefit_notification"
  }
end
