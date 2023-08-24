class NotifyCommentService
  def self.call(params)
    call(params)
  end

  def call(params)
    @params = params
    @user_public_id = params[:public_id]
    @user_id = params[:id]
    @phone = params[:phone]
    @post_title = params[:post_title]
    @post_id = params[:post_id]
  end

  def send_notify_comment
    template_id = KakaoTemplate::POST_COMMENT
    response = BizmsgService.call(
      template_id: template_id,
      phone: Jets.env == "development" ? '01094659404' : @phone,
      message_type: "AT",
      template_params: { target_public_id: @user_public_id, post_id: @post_id, post_title: @post_title }
    )

    send_type = KakaoNotificationResult::POST_COMMENT
    send_id = @user_id
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
      fail_reason = "userid: #{@user_public_id}, error: #{response.dig("error")}"
    end

    KakaoNotificationResult.create!(
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