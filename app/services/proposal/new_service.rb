# frozen_string_literal: true

class Proposal::NewService
  def initialize(params)
    @phone_number = params['phone_number']
    @business_name = params['business_name']
    @customer_info = params['customer_info']
    @work_schedule = params['work_schedule']
    @location_info = params['location_info']
    @tel_link = params['tel_link']
    @accept_link = params['accept_link']
    @deny_link = params['deny_link']
  end

  def call
    KakaoNotificationService.call(
      template_id: KakaoTemplate::CALL_INTERVIEW_PROPOSAL,
      message_type: "AI",
      phone: @phone_number,
      template_params: {
        business_name: @business_name,
        customer_info: @customer_info,
        work_schedule: @work_schedule,
        location_info: @location_info,
        accept_link: @accept_link,
        tel_link: @tel_link,
        deny_link: @deny_link,
      }
    )
  end
end
