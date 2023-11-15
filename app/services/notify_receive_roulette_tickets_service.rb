class NotifyReceiveRouletteTicketsService
  def self.call(user_id)
    new.call(user_id)
  end

  def call(user_id)
    @user = User.find_by(id: user_id, notification_enabled: true)
    if @user.present?
      notify_receive_tickets
    else
      { success: true }
    end
  end

  def notify_receive_tickets
    template_id = MessageTemplateName::ROULETTE
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
      template_params: { name: @user.name }
    )

    send_type = NotificationResult::ROULETTE
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