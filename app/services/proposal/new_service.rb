# frozen_string_literal: true

class Proposal::NewService
  include JobMatchHelper

  def initialize(params)
    @template_id = MessageTemplateName::PROPOSAL
    @target_public_id = params['target_public_id']
    @job_posting_id = params['job_posting_id']
    @job_posting_title = params['job_posting_title']
    @phone_number = params['phone_number']
    @business_name = params['business_name']
    @customer_info = params['customer_info']
    @work_schedule = params['work_schedule']
    @location_info = params['location_info']
    @tel_link = params['tel_link']
    @accept_link = params['accept_link']
    @deny_link = params['deny_link']
    @pay_info = params['pay_info']
    @client_message = params['client_message']
    @user = User.find_by(public_id: @target_public_id)
    @job_posting = JobPosting.find_by(public_id: @job_posting_id)
    @match_info = MatchInfo.new(user: @user, job_posting: @job_posting)
  end

  def call
    response = KakaoNotificationService.call(
      template_id: @template_id,
      message_type: "AI",
      phone: @phone_number,
      template_params: {
        target_public_id: @target_public_id,
        job_posting_id: @job_posting_id,
        job_posting_title: @job_posting_title,
        business_name: @business_name,
        customer_info: @customer_info,
        work_schedule: @work_schedule,
        location_info: @location_info,
        accept_link: @accept_link,
        tel_link: @tel_link,
        deny_link: @deny_link,
        pay_info: @pay_info,
        client_message: @client_message,
        is_high_wage: is_high_wage(
          work_type: @job_posting.work_type,
          pay_type: @job_posting.pay_type,
          wage: @job_posting.max_wage
        ),
        is_can_negotiate_work_time: @job_posting.can_negotiate_work_time,
        is_newbie_appliable: is_newbie_appliable(@job_posting.applying_options),
        is_support_transportation_expences: is_support_transportation_expences(@job_posting.welfare_types),
        **@match_info.to_hash
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
      send_type: NotificationResult::PROPOSAL,
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
