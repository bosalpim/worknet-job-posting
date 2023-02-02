class NotificationJob < ApplicationJob
  include Translation
  include JobPostingsHelper

  def dig
    # user = User.first
    # business = Business.first
    # job_posting = JobPosting.last
    # work_type_ko = translate_type('job_posting', job_posting, :work_type)
    #
    # KakaoNotificationService.call(
    #   template_id: KakaoTemplate::NEW_JOB_POSTING,
    #   phone: '01097912095',
    #   template_params: {
    #     user_name: user.name,
    #     business_name: business.name,
    #     business_vn: job_posting.vn || business.phone_number,
    #     work_type_ko: work_type_ko,
    #     address: job_posting.address,
    #     distance: user.distance_from_ko(job_posting),
    #     pay_text: get_pay_text(job_posting),
    #     job_posting_public_id: ""
    #   }
    # )
  end
end
