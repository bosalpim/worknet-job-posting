# frozen_string_literal: true

class UserPushAlertQueuePrepareJob < ApplicationJob
  cron "10 7 * * ? *"
  def prepare_yoyang_run_push_alert
    if Jets.env.production?
      UserPushAlert::BaseClass.new(
        alert_name: "yoyang_run",
        date: DateTime.now,
        ).prepare
    elsif Jets.env.staging?
      UserPushAlert::BaseClass.new(
        alert_name: "yoyang_run",
        date: DateTime.now,
        batch: 2
      ).prepare
    end
  end

end
