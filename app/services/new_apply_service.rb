class NewApplyService
  attr_reader :apply, :job_posting, :business

  def initialize(apply)
    @apply = apply
    @job_posting = build_job_posting(apply)
    @business = build_business(apply)
  end

  def self.call(apply)
    new(apply).call
  end

  def call
    # 임시 url 지원 페이지 생성되면 교체
    template_id = KakaoTemplate::CALL_REQUEST_ALARM
    short_url = build_short_url(apply)
    response = KakaoNotificationService.call(
      template_id: template_id,
      phone: Jets.env != 'production' ? '01094659404' : job_posting.manager_phone_number,
      template_params: {
        business_name: business.name,
        job_posting_title: job_posting.title,
        job_posting_id: job_posting.public_id,
        apply_id: apply.id,
        auth_token: apply.auth_token,
        short_url: short_url
      }
    )
    save_kakao_notification(
      response,
      KakaoNotificationResult::CALL_REQUEST_ALARM,
      apply.user_id,
      template_id
    )
    response
  end

  private
  def build_short_url(apply)
    template_id = KakaoTemplate::CALL_REQUEST_ALARM
    short_url = ShortUrl.build(
      "https://business.carepartner.kr/employment_management/applies/#{apply.id}?auth_token=#{apply.auth_token}",
      "https://business.carepartner.kr"
    )
    short_url.url
  end

  def build_job_posting(apply)
    JobPosting.find_by(public_id: apply.job_posting_id)
  end

  def build_business(apply)
    apply.business
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