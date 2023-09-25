# frozen_string_literal: true

class Notification::AskActiveService
  def initialize(params)
    @template_id = KakaoTemplate::ASK_ACTIVE
    @phone_number = params["user_phone_number"]
    @user_public_id = params["user_public_id"]
    @user_name = params["user_name"]
    @job_posting_public_id = params["job_posting_public_id"]
    @job_posting_title = params["job_posting_title"]
    @business_name = params["business_name"]
    @url = params["url"]
  end

  def call
    response = BizmsgService.call(
      template_id: KakaoTemplate::ASK_ACTIVE,
      message_type: "AI",
      phone: @phone_number,
      template_params: {
        target_public_id: @user_public_id,
        phone_number: @phone_number,
        title: @job_posting_title,
        job_posting_public_id: @job_posting_public_id,
        business_name: @business_name,
        user_name: @user_name,
        url: @url,
      }
    )

    save_kakao_notification(response, KakaoNotificationResult::ASK_ACTIVE, @user_public_id, @template_id)

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
