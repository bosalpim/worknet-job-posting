# frozen_string_literal: true

class Notification::Factory::NewJobApplication < Notification::Factory::NotificationFactoryClass
  include JobMatchHelper
  include ApplicationHelper
  include JobPostingsHelper

  def initialize(job_application_id)
    super(MessageTemplateName::JOB_APPLICATION)

    @job_application = JobApplication.find(job_application_id)

    unless @job_application.present?
      raise "JobApplication #{job_application_id} is not exists."
    end

    @job_posting = @job_application.job_posting
    @business = @job_posting.business
    @client = @job_posting.client
    @user = @job_application.user
  end

  def create_message
    if @target_medium == APP_PUSH && @client.client_push_tokens.valid.present?
      create_app_push

    end

    create_bizm_message

  end

  def create_bizm_message
    user_info = [user.name, user.korean_gender, user.birth_year.present? ? "#{calculate_korean_age(user.birth_year)}세" : nil]
                  .filter { |i| i.present? }
                  .join('/')
    arlimtalk_utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{MessageTemplateName::JOB_APPLICATION}"
    suffix = "/employment_management/job_applications/#{@job_application.public_id}"

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
      user_message: @job_application.user_message,
      preferred_call_time: @job_application.preferred_call_time,
      type_match: is_type_match(user.preferred_work_types, job_posting.work_type),
      gender_match: is_gender_match(user.preferred_gender, job_posting.gender),
      day_match: is_day_match(user.job_search_days, job_posting.working_days),
      time_match: is_time_match(work_start_time: job_posting.work_start_time, work_end_time: job_posting.work_end_time, job_search_times: user.job_search_times),
      grade_match: is_grade_match(user.preferred_grades, job_posting.grade),
      link: link,
    }
    @bizm_post_pay_list.push(BizmPostPayMessage.new(
      @message_template_id,
      @job_posting.manager_phone_number, params, @client.public_id, 'AI'
    ))
  end

  def create_app_push
    base_url = "#{DEEP_LINK_SCEHEME}/redirect/business"
    to = "employment_management/job_applications/#{@job_application.public_id}"
    link = "#{base_url}?to=#{CGI.escape("#{to}?utm_source=message&utm_campaign=app_push&utm_campaign=#{@message_template_id}")}"
    @client.client_push_tokens.valid.map do |push_token|
      AppPush.new(
        @message_template_id,
        push_token.token,
        @message_template_id,
        {
          title: '요양보호사가 간편지원 했어요!',
          body: '지금바로 지원 메세지와 통화 가능 시간을 확인하고 무료로 전화 응답해 보세요.',
          link: link,
        },
        @client.public_id,
      )
    end

  end
end
