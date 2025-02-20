# frozen_string_literal: true

class UserPushAlertQueuePrepareJob < ApplicationJob

  # user_push_alert_queues table에 전송을 위한 데이터를 넣는 사전 준비 job입니다.
  # 메세지 보내는 시간 최소 15분 전에 실행해야 합니다.

  cron "0 23 * * ? *"
  def quiz_5_push_alert
    prepare_user_push_alert("quiz_5")
  end

  cron "30 9 * * ? *"
  def prepare_yoyang_run_push_alert
    prepare_user_push_alert("yoyang_run")
  end

  cron "30 23 * * ? *"
  def prepare_zodiac_push_alert
    prepare_user_push_alert("daily_chinese_zodiac_fortune")
  end

  cron "30 11 * * ? *"
  def prepare_7d_checkin_push_alert
    prepare_user_push_alert("7_daily_check_in")
  end

  cron "30 2 * * *"
  def prepare_cp_roulette_12
    prepare_user_push_alert("coupang_roulette")
  end

  cron "30 8 * * *"
  def prepare_cp_roulette_18
    prepare_user_push_alert("coupang_roulette")
  end

  cron "30 11 * * *"
  def prepare_cp_roulette_21
    prepare_user_push_alert("coupang_roulette")
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
