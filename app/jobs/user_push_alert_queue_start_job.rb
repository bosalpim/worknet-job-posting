# frozen_string_literal: true

class UserPushAlertQueueStartJob < ApplicationJob
  cron "0 4 * * ? *"
  def start_yoyang_run_push_alert
    if Jets.env.production?
      UserPushAlert::YoyangRunService.new(
        date: DateTime.now,
        ).start
    elsif Jets.env.staging?
      UserPushAlert::YoyangRunService.new(
        date: DateTime.now,
        batch: 2
      ).start
    end
  end

end
