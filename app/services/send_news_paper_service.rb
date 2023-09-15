class SendNewsPaperService
  def self.call(job_search_status)
    new.call(job_search_status)
  end

  def call(job_search_status)
    if Jets.env != "production"
      Jets.logger.info 'Trigger Send News Paper On Staging'
      return
    end

    case job_search_status
    when User::job_search_statuses.dig(:off)
      users = User.off
                  .where(has_certification: true)
                  .where(notification_enabled: true)
      send_message(users, KakaoTemplate::JOB_ALARM_OFF)
    when User::job_search_statuses.dig(:working)
      users = User.working
                  .where(has_certification: true)
                  .where(notification_enabled: true)
      send_message(users, KakaoTemplate::JOB_ALARM_WORKING)
    else
      # active/common은 lambda에 redis를 적용하기 전까지 새벽에 생성하고 아침에는 나눠서 전송하도록 합니다.
      return
    end
  end

  private

  def send_message(users, template_id)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []

    users.each do |user|
      response = KakaoNotificationService.call(
        template_id: template_id,
        message_type: "AI",
        phone: user.phone_number,
        template_params: { lat: user.lat, lng: user.lng }
      )

      if response.dig("code") == "success"
        if response.dig("message") == "K000"
          success_count += 1
        else
          tms_success_count += 1
        end
      else
        fail_count += 1
      end
      fail_reasons.push(response.dig("originMessage")) if response.dig("message") != "K000"
    end

    KakaoNotificationResult.create!(
      send_type: KakaoNotificationResult::NEWS_PAPER,
      template_id: template_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons.uniq.join(", ")
    )
  end
end