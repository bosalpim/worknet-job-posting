# frozen_string_literal: true

class JobPostingJob < ApplicationJob

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
