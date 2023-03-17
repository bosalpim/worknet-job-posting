class NewSatisfactionSurveyService
  attr_reader :job_posting, :user

  def initialize(job_posting, user_id)
    @job_posting = job_posting
    @user = build_user(user_id)
  end

  def self.call(job_posting, user_id)
    new(job_posting, user_id).call
  end

  def call
    business = job_posting.business
    short_url = ShortUrl.build(
      "https://business.carepartner.kr/satisfaction_surveys/#{job_posting.public_id}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=satisfaction_survey_follow_up",
      "https://business.carepartner.kr"
    )

    template_id = KakaoTemplate::SATISFACTION_SURVEY
    response = KakaoNotificationService.call(
      template_id: template_id,
      phone: Jets.env != 'production' ? '01097912095' : user.phone_number,
      template_params: {
        business_name: business.name,
        job_posting_title: job_posting.title,
        job_posting_public_id: job_posting.public_id,
        link: short_url.url
      }
    )
    save_kakao_notification(response, KakaoNotificationResult::SATISFACTION_SURVEY, job_posting.id, template_id)
    response
  end

  private

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

  def build_user(user_id)
    User.find(user_id)
  end
end