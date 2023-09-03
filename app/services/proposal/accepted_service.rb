# frozen_string_literal: true

class Proposal::AcceptedService
  def initialize(params)
    p params
    @template_id = KakaoTemplate::CALL_INTERVIEW_ACCEPTED
    @business_id = params["business_id"]
    @job_posting_id = params["job_posting_id"]
    @phone_number = params["phone_number"]
    @tel_link = params["tel_link"]
    @job_posting_title = params["job_posting_title"]
    @user_info = params["user_info"]
    @accepted_at = params["accepted_at"]
    @address = params["address"]
  end

  def call
    response = KakaoNotificationService.call(
      template_id: @template_id,
      message_type: "AI",
      phone: @phone_number,
      template_params: {
        tel_link: @tel_link,
        job_posting_title: @job_posting_title,
        user_info: @user_info,
        accepted_at: @accepted_at,
        address: @address
      }
    )

    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reason = ""

    code = response.dig("code")
    message = response.dig("message")

    if code == 'success' && message == 'K000'
      success_count = 1
    elsif code == 'success'
      tms_success_count = 1
    else
      fail_count = 1
    end
    fail_reason = response.dig('originMessage') if code != 'success'

    KakaoNotificationResult.create(
      template_id: @template_id,
      send_type: KakaoNotificationResult::CALL_INTERVIEW_ACCEPTED,
      send_id: @client_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reason
    )

    {
      code: code,
      response: message
    }
  end
end
