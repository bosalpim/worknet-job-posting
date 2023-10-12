class GamificationMissionCompleteService

  attr_reader :user

  def initialize(user_id)
    @user = User.find_by(id: user_id)
  end

  def send_mission_complete_message
    template_id = MessageTemplate::GAMIFICATION_MISSION_COMPLETE
    response = BizmsgService.call(
      template_id: template_id,
      phone: Jets.env == "production" ? user.phone_number : '01049195808',
      message_type: "AI",
      template_params: {}
    )

    send_type = NotificationResult::GAMIFICATION_MISSION_COMPLETE
    send_id = user.id
    save_kakao_notification(response, send_type, send_id, template_id)
    response
  end

  private
  def save_kakao_notification(response, send_type, send_id, template_id)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reason = ""

    if response.dig("result") == "Y"
      if response.dig("code") == "K000"
        success_count += 1
      else
        tms_success_count += 1
      end
    else
      fail_count += 1
      fail_reason = response.dig("error")
    end

    NotificationResult.create!(
      send_type: send_type,
      send_id: send_id,
      template_id: template_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reason
    )
  end
end