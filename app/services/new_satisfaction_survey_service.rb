class NewSatisfactionSurveyService
  def initialize(job_posting)
    @job_posting = job_posting
  end

  def self.call(job_posting)
    new(job_posting).call
  end

  def call
    business = job_posting.business
    KakaoNotificationService.call(
      template_id: KakaoTemplate::SATISFACTION_SURVEY,
      phone: Jets.env != 'production' ? '01097912095' : user.phone_number,
      template_params: {
        business_name: business.name,
        job_posting_title: job_posting.title,
        job_posting_public_id: job_posting.public_id
      }
    )
  end
end