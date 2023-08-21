class UserCallFailureAlertService
  attr_reader :user, :job_posting, :business, :client

  def initialize(user, job_posting)
    @user = user
    @job_posting = job_posting
    @business = build_business(job_posting)
    @client = build_client(job_posting)
  end

  def self.call(user, job_posting)
    new(user, job_posting).call
  end

  def call
    template_id = KakaoTemplate::BUSINESS_CALL_REMINDER

    response = KakaoNotificationService.call(
      template_id: template_id,
      phone: Jets.env != 'production' ? '01094659404' : job_posting.manager_phone_number,
      template_params: {
        user_name: user.name,
        business_name: business.name,
        target_public_id: client.public_id,
        job_posting_title: job_posting.title,
        job_posting_public_id: job_posting.public_id,
        called_at: (Time.current + 9.hour - 1.minute).strftime("%Y-%m-%d %H시%M분 경")
      }
    )
    save_kakao_notification(
      response,
      KakaoNotificationResult::USER_CALL_FAILURE_ALERT,
      job_posting.id,
      template_id
    )
    response
  end

  private

  def build_business(job_posting)
    job_posting.business
  end

  def build_client(job_posting)
    job_posting.client
  end

  def save_kakao_notification(response, send_type, send_id, template_id)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reason = ""

    if response.dig("code") == "success"
      if response.dig("message") == "K000"
        success_count += 1
      else
        tms_success_count += 1
      end
    else
      fail_count += 1
      fail_reason = response.dig("originMessage")
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