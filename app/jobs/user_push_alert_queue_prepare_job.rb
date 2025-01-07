# frozen_string_literal: true

class UserPushAlertQueuePrepareJob < ApplicationJob

  # user_push_alert_queues table에 전송을 위한 데이터를 넣는 사전 준비 job입니다.
  # 메세지 보내는 시간 최소 15분 전에 실행해야 합니다.

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
