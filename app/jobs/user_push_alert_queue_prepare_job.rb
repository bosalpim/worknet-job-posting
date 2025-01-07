# frozen_string_literal: true

class UserPushAlertQueuePrepareJob < ApplicationJob
  cron "50 7 * * ? *"
  def prepare_yoyang_run_push_alert
    prepare_user_push_alert("yoyang_run")
  end

  def prepare_user_push_alert(alert_name)
    if Jets.env.production?
      UserPushAlert::BaseClass.new(
        alert_name: alert_name,
        date: DateTime.now,
        ).prepare
    elsif Jets.env.staging?
      UserPushAlert::BaseClass.new(
        alert_name: alert_name,
        date: DateTime.now,
        batch: 2
      ).prepare
    end
  end

end
