class BusinessCallFailureAlertService
  attr_reader :proposal, :job_posting, :business, :user

  def initialize(proposal)
    @proposal = proposal
    @job_posting = build_job_posting(proposal)
    @business = build_business(proposal)
    @user = build_user(proposal)
  end

  def self.call(proposal)
    new(proposal).call
  end

  def call
    template_id = KakaoTemplate::USER_CALL_REMINDER
    response = KakaoNotificationService.call(
      template_id: template_id,
      phone: Jets.env != 'production' ? '01097912095' : user.phone_number,
      template_params: {
        user_name: user.name,
        business_name: business.name,
        job_posting_title: job_posting.title,
        business_vn: good_number(proposal.user_vn)
      }
    )
    save_kakao_notification(
      response,
      KakaoNotificationResult::BUSINESS_CALL_FAILURE_ALERT,
      proposal.id,
      template_id
    )
    response
  end

  private

  def build_job_posting(proposal)
    JobPosting.find_by(public_id: proposal.job_posting_id)
  end

  def build_business(proposal)
    proposal.business
  end

  def build_user(proposal)
    proposal.user
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
      phone_number&.slice(0, 3) + "-" +  phone_number&.slice(3..)&.scan(/.{4}/)&.join('-') rescue nil
    end
  end
end