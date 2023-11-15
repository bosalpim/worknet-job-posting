# frozen_string_literal: true

class JobApplication::NewService
  include JobPostingsHelper
  include JobMatchHelper
  include Notification

  def initialize(
    job_application_public_id:
  )
    @job_application = JobApplication.find_by(
      public_id: job_application_public_id
    )
  end

  def call
    user = @job_application.user
    job_posting = @job_application.job_posting
    business = Business.find(job_posting.business_id)
    client = Client.find(job_posting.client_id)

    user_info = [user.name, user.korean_gender, user.birth_year.present? ? "#{calculate_korean_age(user.birth_year)}세" : nil]
                  .filter { |i| i.present? }
                  .join('/')

    # TODO 문자 오픈율 높을 경우, 리팩토링
    arlimtalk_utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{MessageTemplateName::JOB_APPLICATION}"
    textmessage_utm = "utm_source=text_message&utm_medium=text_message&utm_campaign=#{MessageTemplateName::JOB_APPLICATION}"
    suffix = "/employment_management/job_applications/#{@job_application.public_id}"
    host = if Jets.env.production?
             "https://business.carepartner.kr"
           elsif Jets.env.staging?
             "https://staging-business.carepartner.kr"
           else
             "http://localhost:3001"
           end

    link = if Jets.env.production?
             "https://business.carepartner.kr#{suffix}?#{arlimtalk_utm}"
           elsif Jets.env.staging?
             "https://staging-business.vercel.app#{suffix}?#{arlimtalk_utm}"
           else
             "https://staging-business.vercel.app#{suffix}?#{arlimtalk_utm}"
           end

    textmessage_url = ShortUrl.build(if Jets.env.production?
                                       "https://business.carepartner.kr#{suffix}?#{textmessage_utm}"
                                     elsif Jets.env.staging?
                                       "https://staging-business.vercel.app#{suffix}?#{textmessage_utm}"
                                     else
                                       "http://localhost:3001#{suffix}?#{textmessage_utm}"
                                     end, host)

    if Lms.new(
      phone_number: job_posting.manager_phone_number,
      message: "#{user_info}요양보호사가 지원했어요.

■ 지원자의 한마디
“#{@job_application.user_message}”

■ 공고
#{job_posting.title}

■ 통화 가능한 시간
#{@job_application.preferred_call_time}

아래 링크를 눌러 지원자의 자세한 정보를 확인하고 무료로 전화해 보세요!

#{textmessage_url.url}").send
      AmplitudeService.instance.log_array([{
                                             "user_id" => client.public_id,
                                             "event_type" => KakaoNotificationLoggingHelper::NOTIFICATION_EVENT_NAME,
                                             "event_properties" => {
                                               type: 'text_message',
                                               template: MessageTemplateName::JOB_APPLICATION,
                                               jobPostingId: job_posting.public_id,
                                               title: job_posting.title,
                                               employee_id: user.public_id
                                             }
                                           }])
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
