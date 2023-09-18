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

    save_kakao_notification(response, KakaoNotificationResult::ASK_ACTIVE, @user_public_id, template_id)

    response
  end
end
