# frozen_string_literal: true

class Notification::Factory::ConfirmCareerCertification < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include JobMatchHelper
  include Notification
  include KakaoNotificationLoggingHelper
  
  def initialize(career_certification_public_id)
    super(MessageTemplateName::CONFIRM_CAREER_CERTIFICATION)

    @career_certification = CareerCertification.find_by(public_id: career_certification_public_id)

    unless @career_certification.present?
      raise "Career certification #{career_certification_public_id} not exists"
    end

    @job_posting = @career_certification.job_posting
    @user = @career_certification.user
    @client = @job_posting.client
    @business = @job_posting.business
    create_message
  end

  def create_message
    if @target_medium == APP_PUSH && @client.client_push_tokens.valid.present?
      return create_app_push_message
    end

    create_bizm_message
  end

  def create_app_push_message
    base_url = "#{DEEP_LINK_SCEHEME}/redirect/business"
    to = "/recruitment_management/#{@job_posting.public_id}/close/select_caregiver"
    link = "#{base_url}?to=#{CGI.escape("#{to}?utm_source=message&utm_campaign=app_push&utm_campaign=#{@message_template_id}")}"
    @app_push_list.push(
      *@client.client_push_tokens.valid.map do |push_token|
        AppPush.new(
          @message_template_id,
          push_token.token,
          @message_template_id,
          {
            title: '요양보호사가 채용인증을 요청했어요.',
            body: '채용 결과 입력 후 전화번호 열람권(3장)을 받아 보세요.',
            link: link,
          },
          @client.public_id,
          {
            "type" => NOTIFICATION_TYPE_APP_PUSH,
            "template" => @message_template_id,
            "centerName" => @business.name,
            "jobPostingId" => @job_posting.public_id,
            "employee_id" => @user.public_id,
            "title" => @job_posting.title,
            "type_match" => is_type_match(@user.preferred_work_types, @job_posting.work_type),
            "gender_match" => is_gender_match(@user.preferred_gender, @job_posting.gender),
            "day_match" => is_day_match(@user.job_search_days, @job_posting.working_days),
            "time_match" => is_time_match(work_start_time: @job_posting.work_start_time, work_end_time: @job_posting.work_end_time, job_search_times: @user.job_search_times),
            "grade_match" => is_grade_match(@user.preferred_grades, @job_posting.grade)
          }
        )
      end
    )
  end

  def create_bizm_message

    user_info = [@user.name, @user.korean_gender, @user.birth_year.present? ? "#{calculate_korean_age(@user.birth_year)}세" : nil]
                  .filter { |i| i.present? }
                  .join('/')

    arlimtalk_utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    suffix = "/recruitment_management/#{@job_posting.public_id}/close/select_caregiver"

    link = if Jets.env.production?
             "https://business.carepartner.kr#{suffix}?#{arlimtalk_utm}"
           elsif Jets.env.staging?
             "https://staging-business.vercel.app#{suffix}?#{arlimtalk_utm}"
           else
             "https://staging-business.vercel.app#{suffix}?#{arlimtalk_utm}"
           end

    params = {
      target_public_id: @client.public_id,
      job_posting_public_id: @job_posting.public_id,
      job_posting_title: @job_posting.title,
      user_public_id: @user.public_id,
      business_name: @business.name,
      user_info: user_info,
      user_message: @career_certification.user_message,
      preferred_call_time: @career_certification.preferred_call_time,
      type_match: is_type_match(@user.preferred_work_types, @job_posting.work_type),
      gender_match: is_gender_match(@user.preferred_gender, @job_posting.gender),
      day_match: is_day_match(@user.job_search_days, @job_posting.working_days),
      time_match: is_time_match(work_start_time: @job_posting.work_start_time, work_end_time: @job_posting.work_end_time, job_search_times: @user.job_search_times),
      grade_match: is_grade_match(@user.preferred_grades, @job_posting.grade),
      link: link,
    }

    @bizm_post_pay_list.push(
      BizmPostPayMessage.new(
        @message_template_id,
        @job_posting.manager_phone_number,
        params,
        @client.public_id,
        "AI"
      )
    )
  end
end
