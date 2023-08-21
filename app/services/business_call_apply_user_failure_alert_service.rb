class BusinessCallApplyUserFailureAlertService
  attr_reader :apply, :job_posting, :business, :user, :client

  def initialize(apply)
    @apply = apply
    @job_posting = build_job_posting(apply)
    @business = build_business(apply)
    @client = build_client(job_posting)
    @user = build_user(apply)

  end

  def self.call(apply)
    new(apply).call
  end

  def call
    template_id = KakaoTemplate::BUSINESS_CALL_APPLY_USER_REMINDER
    business_telnumber = job_posting.vn.nil? ? business.tel_number : job_posting.vn
    response = KakaoNotificationService.call(
      template_id: template_id,
      phone: Jets.env != 'production' ? '01094659404' : user.phone_number,
      template_params: {
        target_public_id: client.public_id,
        user_name: user.name,
        employee_id: user.public_id,
        business_name: business.name,
        job_posting_title: job_posting.title,
        job_posting_public_id: job_posting.public_id,
        business_vn: good_number(business_telnumber)
      }
    )
    save_kakao_notification(
      response,
      KakaoNotificationResult::BUSINESS_CALL_APPLY_USER_FAILURE_ALERT,
      apply.id,
      template_id
    )
    response
  end

  private

  def build_job_posting(apply)
    JobPosting.find_by(public_id: apply.job_posting_id)
  end

  def build_business(apply)
    apply.business
  end

  def build_client(job_posting)
    job_posting.client
  end

  def build_user(apply)
    apply.user
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

  def good_number(phone_number)
    if phone_number&.length == 12
      phone_number&.scan(/.{4}/)&.join('-')
    else
      phone_number&.slice(0, 3) + "-" + phone_number&.slice(3..)&.scan(/.{4}/)&.join('-') rescue nil
    end
  end
end