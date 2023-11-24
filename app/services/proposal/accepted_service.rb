# frozen_string_literal: true

class Proposal::AcceptedService
  include JobMatchHelper

  def initialize(params)
    @template_id = MessageTemplateName::CALL_INTERVIEW_ACCEPTED
    @target_public_id = params['target_public_id']
    @business_id = params["business_id"]
    @business_name = params["business_name"]
    @job_posting_id = params["job_posting_id"]
    @job_posting_title = params["job_posting_title"]
    @employee_id = params["employee_id"]
    @phone_number = params["phone_number"]
    @tel_link = params["tel_link"]
    @user_info = params["user_info"]
    @user_name = params["user_name"]
    @accepted_at = params["accepted_at"]
    @address = params["address"]
    @client_message = params["client_message"]
    @job_posting = JobPosting.find_by(public_id: @job_posting_id)
  end

  def call
    response = KakaoNotificationService.call(
      template_id: @template_id,
      message_type: "AI",
      phone: @phone_number,
      template_params: {
        target_public_id: @target_public_id,
        employee_id: @employee_id,
        job_posting_id: @job_posting_id,
        job_posting_title: @job_posting_title,
        business_name: @business_name,
        tel_link: @tel_link,
        user_name: @user_name,
        user_info: @user_info,
        accepted_at: @accepted_at,
        address: @address,
        client_message: @client_message,
        is_high_wage: is_high_wage(
          work_type: @job_posting.work_type,
          pay_type: @job_posting.pay_type,
          wage: @job_posting.max_wage
        ),
        is_can_negotiate_work_time: @job_posting.can_negotiate_work_time,
        is_newbie_appliable: is_newbie_appliable(@job_posting.applying_options),
        is_support_transportation_expences: is_support_transportation_expences(@job_posting.welfare_types),
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

    NotificationResult.create(
      template_id: @template_id,
      send_type: NotificationResult::CALL_INTERVIEW_ACCEPTED,
      send_id: @target_public_id,
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
