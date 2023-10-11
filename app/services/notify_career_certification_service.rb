# frozen_string_literal: true

class NotifyCareerCertificationService
  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @template_id = MessageTemplate::CAREER_CERTIFICATION
    @link = params.dig(:link)
    @phone = params.dig(:phone)
    @center_name = params.dig(:center_name)
    @job_posting_title = params.dig(:job_posting_title)
  end

  def call
    send
  end

  private

  def send()
    reserve_dt = (DateTime.now + 3.days).in_time_zone('Seoul').strftime('%Y%m%d%H%M%S')
    response = KakaoNotificationService.call(
      template_id: @template_id,
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

    KakaoNotificationResult.create!({
                                      send_type: KakaoNotificationResult::CAREER_CERTIFICATION,
                                      send_id: @job_posting_title,
                                      template_id: @template_id,
                                      success_count: success_count,
                                      tms_success_count: tms_success_count,
                                      fail_count: fail_count,
                                      fail_reasons: fail_reasons
                                    })
  end
end
