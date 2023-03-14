class NewSatisfactionSurveyService
  def initialize(job_posting)
    @job_posting = job_posting
  end

  def self.call(job_posting)
    new(job_posting).call
  end

  def call
    business = job_posting.business
    short_url = ShortUrl.build(
      "https://business.carepartner.kr/satisfaction_surveys/#{job_posting.public_id}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=satisfaction_survey_follow_up",
      "https://business.carepartner.kr"
    )

    puts short_url.url
    KakaoNotificationService.call(
      template_id: KakaoTemplate::SATISFACTION_SURVEY,
      phone: Jets.env != 'production' ? '01097912095' : user.phone_number,
      template_params: {
        business_name: business.name,
        job_posting_title: job_posting.title,
        job_posting_public_id: job_posting.public_id,
        link: short_url.url
      }
    )
  end
end