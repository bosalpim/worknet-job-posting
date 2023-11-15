class NewApplyService
  include Notification

  attr_reader :apply, :job_posting, :business, :client, :user

  def initialize(apply)
    @apply = apply
    @user = apply.user
    @job_posting = build_job_posting(apply)
    @business = build_business(apply)
    @client = build_client(business)
  end

  def self.call(apply)
    new(apply).call
  end

  def call
    # 임시 url 지원 페이지 생성되면 교체
    template_id = MessageTemplateName::CALL_REQUEST_ALARM
    short_url = build_short_url(apply)

    response = KakaoNotificationService.call(
      template_id: template_id,
      phone: job_posting.manager_phone_number,
      template_params: {
        target_public_id: client.public_id,
        business_name: business.name,
        job_posting_title: job_posting.title,
        job_posting_public_id: job_posting.public_id,
        job_posting_id: job_posting.public_id,
        employee_id: user.public_id,
        apply_id: apply.id,
        auth_token: apply.auth_token,
        short_url: short_url
      }
    )
    send_text_message(
      phone_number: job_posting.manager_phone_number,
      business_name: business.name,
      job_posting_title: job_posting.title,
      short_url: build_mobile_url(apply)
    )
    save_kakao_notification(
      response,
      NotificationResult::CALL_REQUEST_ALARM,
      apply.user_id,
      template_id
    )
    response
  end

  private

  def build_mobile_url(apply)
    template_id = MessageTemplateName::CALL_REQUEST_ALARM
    base_url = if Jets.env.production?
                 "https://business.carepartner.kr"
               elsif Jets.env.staging?
                 "https://staging-business.vercel.app"
               else
                 "http://localhost:3001"
               end

    utm_part = "utm_source=textmessage&utm_medium=textmessage&utm_campaign=#{template_id}"
    short_url = ShortUrl.build(
      base_url + "/employment_management/applies/#{apply.id}?auth_token=#{apply.auth_token}&#{utm_part}",
      base_url
    )
    short_url.url
  end

  def send_text_message(
    phone_number:,
    business_name:,
    job_posting_title:,
    short_url:
  )
    if Lms.new(
      phone_number: phone_number,
      message: "[케어파트너] 전화요청 알림

#{business_name} 담당자님
등록하신 공고에 전화를 요청한 요양보호사가 있습니다.

아래 버튼 혹은 링크를 눌러 요양보호사 정보를 확인하고 전화해보세요.
빠르게 연락할수록 채용확률이 높아집니다.

공고명: #{job_posting_title}
링크: #{short_url}"
    ).send
      AmplitudeService.instance.log_array([{
                                             "user_id" => @client.public_id,
                                             "event_type" => KakaoNotificationLoggingHelper::NOTIFICATION_EVENT_NAME,
                                             "event_properties" => {
                                               template: MessageTemplateName::CALL_REQUEST_ALARM,
                                               jobPostingId: @job_posting.public_id,
                                               title: @job_posting.title,
                                               employee_id: @user.public_id
                                             }
                                           }])
    end
  end

  def build_short_url(apply)
    template_id = MessageTemplateName::CALL_REQUEST_ALARM
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

  def build_client(business)
    business.clients.first
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

    NotificationResult.create!(
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