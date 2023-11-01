class ActiveUserServiceGuideService
  def self.call(user_id, treatment_key)
    new.call(user_id, treatment_key)
  end

  def call(user_id, treatment_key)
    @user = User.find_by(id: user_id, notification_enabled: true)
    @treatment_key = treatment_key
    if @user.present?
      send_signup_complete_guide
    else
      { success: true }
    end
  end

  def send_signup_complete_guide
    template_id = (@treatment_key == 'B') ? MessageTemplateName::SIGNUP_COMPLETE_GUIDE3 : MessageTemplateName::SIGNUP_COMPLETE_GUIDE
    phone = if Jets.env == 'production'
              @user.phone_number
            elsif PHONE_NUMBER_WHITELIST.is_a?(Array) && PHONE_NUMBER_WHITELIST.include?(@user.phone_number)
              @user.phone_number
            else
              TEST_PHONE_NUMBER
            end
    response = BizmsgService.call(
      template_id: template_id,
      phone: phone,
      message_type: "AI",
      template_params: { target_public_id: @user.public_id }
    )

    send_type = NotificationResult::SIGNUP_COMPLETE_GUIDE
    send_id = @user.id
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
      fail_reason = "userid: #{@user.public_id}, error: #{response.dig("error")}"
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