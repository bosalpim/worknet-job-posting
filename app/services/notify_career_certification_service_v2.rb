# frozen_string_literal: true

class NotifyCareerCertificationServiceV2
  def initialize(params)
    @link = params.dig(:link)
    @phone = params.dig(:phone)
    @user_id = params.dig(:user_id)
    @center_name = params.dig(:center_name)
    @job_posting_title = params.dig(:job_posting_title)
  end

  def call
    treatment = Bex::FetchTreatmentByUserIdService.new(
      experiment_key: Bex::Experiment::CAREER_CERTIFICATION,
      user_id: @user_id
    ).call

    if treatment.nil?
      Jets.logger.error "Treatment not found for user #{@user_id}"

      return
    end

    template_id = treatment.key == 'A' ?
                    MessageTemplateName::CONNECT_RESULT_USER_SURVEY_A :
                    MessageTemplateName::CONNECT_RESULT_USER_SURVEY_B

    reserve_dt = (DateTime.now + 3.days).in_time_zone('Seoul').strftime('%Y%m%d%H%M%S')
    
    response = KakaoNotificationService.call(
      template_id: template_id,
      message_type: 'AI',
      phone: @phone,
      template_params: {
        link: @link,
        center_name: @center_name,
        job_posting_title: @job_posting_title
      },
      reserve_dt: Jets.env == 'production' ? reserve_dt : nil
    )

    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = ''

    code = response.dig('code')
    message = response.dig('message')

    if code == 'success' && message == 'K000'
      success_count += 1
    elsif code == 'success'
      tms_success_count += 1
    else
      fail_count += 1
      fail_reasons = response.dig("originMessage")
    end

    NotificationResult.create!({
                                 send_type: NotificationResult::CAREER_CERTIFICATION,
                                 send_id: @job_posting_title,
                                 template_id: @template_id,
                                 success_count: success_count,
                                 tms_success_count: tms_success_count,
                                 fail_count: fail_count,
                                 fail_reasons: fail_reasons
                               })
  end
end
