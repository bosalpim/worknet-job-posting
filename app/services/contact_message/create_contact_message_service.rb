# frozen_string_literal: true

class ContactMessage::CreateContactMessageService
  include JobPostingsHelper
  include JobMatchHelper
  include Notification

  def initialize(
    contact_message_public_id:
  )
    @contact_message = ContactMessage.find_by(
      public_id: contact_message_public_id
    )
  end

  def call
    user = @contact_message.user
    job_posting = @contact_message.job_posting
    business = Business.find(job_posting.business_id)
    client = Client.find(job_posting.client_id)

    user_info = [user.name, user.korean_gender, user.birth_year.present? ? "#{calculate_korean_age(user.birth_year)}세" : nil]
                  .filter { |i| i.present? }
                  .join('/')

    arlimtalk_utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{MessageTemplateName::CONTACT_MESSAGE}"
    suffix = "/employment_management/job_applications/#{@contact_message.public_id}"

    link = if Jets.env.production?
             "https://business.carepartner.kr#{suffix}?#{arlimtalk_utm}"
           elsif Jets.env.staging?
             "https://staging-business.vercel.app#{suffix}?#{arlimtalk_utm}"
           else
             "https://staging-business.vercel.app#{suffix}?#{arlimtalk_utm}"
           end

    KakaoNotificationService.call(
      template_id: MessageTemplateName::CONTACT_MESSAGE,
      message_type: "AI",
      phone: job_posting.manager_phone_number,
      template_params: {
        target_public_id: client.public_id,
        job_posting_public_id: job_posting.public_id,
        job_posting_title: job_posting.title,
        user_public_id: user.public_id,
        business_name: business.name,
        user_info: user_info,
        user_message: @contact_message.user_message,
        preferred_call_time: @contact_message.preferred_call_time,
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
