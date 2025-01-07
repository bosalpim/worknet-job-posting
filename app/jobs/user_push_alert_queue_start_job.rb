# frozen_string_literal: true

class UserPushAlertQueueStartJob < ApplicationJob
  cron "0 4 * * ? *"
  def start_send_yoyang_run_push
    UserPushAlert::BaseClass.new(
      alert_name: "yoyang_run",
      date: DateTime.now,
      batch: 2
    ).start
  end

end
