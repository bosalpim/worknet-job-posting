# frozen_string_literal: true

class Notification::Factory::NewContactMessage < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include JobMatchHelper
  include NotificationType
  include KakaoNotificationLoggingHelper

  def initialize(contact_message_public_id)
    super(MessageTemplateName::CONTACT_MESSAGE)
    @contact_message = ContactMessage.find_by(public_id: contact_message_public_id)
    raise "Contact Message #{contact_message_public_id} not exists" unless @contact_message

    @job_posting = @contact_message.job_posting
    @user = @contact_message.user
    @client = @job_posting.client
    @business = @job_posting.business
    create_message
  end

  def create_message
    return create_app_push_message if app_push_target?

    create_bizm_message
  end

  private

  def create_app_push_message
    link = format_app_push_link
    @app_push_list.push(
      *@client.client_push_tokens.valid.map { |push_token| build_app_push(push_token, link) }
    )
  end

  def format_app_push_link
    base_url = "#{Main::Application::DEEP_LINK_SCHEME}/redirect/business"
    to = "employment_management/contact_messages/#{@contact_message.public_id}"
    "#{base_url}?to=#{CGI.escape("#{to}?utm_source=message&utm_campaign=app_push&utm_campaign=#{@message_template_id}")}"
  end

  def build_app_push(push_token, link)
    AppPush.new(
      @message_template_id,
      push_token.token,
      @message_template_id,
      push_notification_content(link),
      @client.public_id,
      push_notification_data
    )
  end

  def push_notification_content(link)
    {
      title: '요양보호사가 문자문의 했어요!',
      body: '지금바로 문의 내용과 통화가능 시간을 확인하고 무료로 전화 응답해 보세요.',
      link: link
    }
  end

  def push_notification_data
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
  end

  def create_bizm_message

    user_info = format_user_info
    arlimtalk_utm = format_arlimtalk_utm
    link = format_link("/employment_management/contact_messages/#{@contact_message.public_id}", arlimtalk_utm)
    close_link = format_link("/recruitment_management/#{@job_posting.public_id}/close", arlimtalk_utm)

    params = build_params(user_info, link, close_link)

    @bizm_post_pay_list.push(
      BizmPostPayMessage.new(
        @message_template_id,
        @job_posting.manager_phone_number,
        params,
        @client.public_id,
        "AI", nil, [0]
      )
    )
  end

  def app_push_target?
    @target_medium == APP_PUSH && @client.client_push_tokens.valid.present?
  end

  def format_user_info
    [@user.name, @user.korean_gender, @user.birth_year.present? ? "#{calculate_korean_age(@user.birth_year)}세" : nil]
      .filter(&:present?)
      .join('/')
  end

  def format_arlimtalk_utm
    "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
  end

  def format_link(suffix, arlimtalk_utm)
    base_url = if Jets.env.production?
                 "https://business.carepartner.kr"
               else
                 "https://staging-business.vercel.app"
               end
    "#{base_url}#{suffix}?#{arlimtalk_utm}"
  end

  def build_params(user_info, link, close_link)
    {
      target_public_id: @client.public_id,
      job_posting_public_id: @job_posting.public_id,
      job_posting_title: @job_posting.title,
      user_public_id: @user.public_id,
      business_name: @business.name,
      user_info: user_info,
      user_message: @contact_message.user_message,
      preferred_call_time: @contact_message.preferred_call_time,
      type_match: is_type_match(@user.preferred_work_types, @job_posting.work_type),
      gender_match: is_gender_match(@user.preferred_gender, @job_posting.gender),
      day_match: is_day_match(@user.job_search_days, @job_posting.working_days),
      time_match: is_time_match(work_start_time: @job_posting.work_start_time, work_end_time: @job_posting.work_end_time, job_search_times: @user.job_search_times),
      grade_match: is_grade_match(@user.preferred_grades, @job_posting.grade),
      link: link,
      close_link: close_link
    }
  end

end
