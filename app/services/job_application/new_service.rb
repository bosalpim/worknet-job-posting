# frozen_string_literal: true

class JobApplication::NewService
  include JobPostingsHelper
  include JobMatchHelper

  def initialize(
    job_application_public_id:
  )
    @job_application = JobApplication.find_by(job_application_public_id)
  end

  def call
    user = @job_application.user
    job_posting = @job_application.job_posting
    business = Business.find(job_posting.business_id)
    client = Client.find(job_posting.client_id)

    user_info = [user.name[0] + '**', user.korean_gender, "#{calculate_korean_age(user.birth_year)}세"]
                  .filter { |i| i.present? }
                  .join('/')

    suffix = "/employment_management/job_applications/#{@job_application.public_id}"
    link = if Jets.env.production?
             "https://business.carepartner.kr#{suffix}"
           elsif Jets.env.staging?
             "https://staging-business.vercel.app#{suffix}"
           else
             "https://localhost:3001#{suffix}"
           end

    KakaoNotificationService.call(
      template_id: MessageTemplateName::JOB_APPLICATION,
      message_type: "AI",
      phone: job_posting.manager_phone_number,
      template_params: {
        target_public_id: client.public_id,
        job_posting_public_id: job_posting.public_id,
        job_posting_title: job_posting.title,
        user_public_id: user.public_id,
        business_name: business.name,
        user_info: user_info,
        user_message: @job_application.user_message,
        preferred_call_time: @job_application.preferred_call_time,
        type_match: is_type_match(user.preferred_work_types, job_posting.work_type),
        gender_match: is_gender_match(user.preferred_gender, job_posting.gender),
        day_match: is_day_match(user.job_search_days, job_posting.working_days),
        time_match: is_time_match(work_start_time: job_posting.work_start_time, work_end_time: job_posting.work_end_time, job_search_times: user.job_search_times),
        grade_match: is_grade_match(user.preferred_grades, job_posting.grade),
        link: link,
      }
    )
  end
end
