# frozen_string_literal: true

class JobPostingJob < ApplicationJob
  include Translation
  include NotificationType
  include JobPostingsHelper

  KOREAN_OFFSET = 9.hours
  RESERVE_TARGET_TIME = 8.hours

  cron "0 1 * * ? *"
  def notify_expiration_date(date = nil)
    now = date.nil? ? DateTime.now : date

    JobPosting::NotifyExpirationDateService.call(
      DateTime.new(
        now.year,
        now.month,
        now.day, 1, 0, 0
      ).in_time_zone('Seoul')
    )
  end
end
