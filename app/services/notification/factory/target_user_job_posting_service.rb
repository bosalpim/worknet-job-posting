# frozen_string_literal: true

class Notification::Factory::TargetUserJobPostingService < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include DispatchedNotificationsHelper
  include AlimtalkMessage

  DispatchedNotificationService = Notification::Factory::DispatchedNotifications::Service

  def initialize(params)
    super(MessageTemplates::TEMPLATES[MessageNames::TARGET_USER_JOB_POSTING])
    @job_posting = JobPosting.find(params[:job_posting_id])
    @base_url = "#{Main::Application::CAREPARTNER_URL}/jobs/#{@job_posting.public_id}"
    @deeplink_scheme = Main::Application::DEEP_LINK_SCHEME
    @list = User
              .receive_job_notifications
              .within_radius(
                @job_posting.is_facility? ? 5000 : 3000,
                @job_posting.lat,
                @job_posting.lng,
              ).where.not(phone_number: nil)
              .where(phone_number: '01049195808')

    @dispatched_notifications_service = DispatchedNotificationService.call(@message_template_id, "target_message", @job_posting.id, "yobosa")
    create_message
  end

  def create_message
    @list.each do |user|
      unless user.is_a?(User)
        next
      end

      message = create_arlimtalk(
        user
      )

      @bizm_post_pay_list.push(message) if message.present?
    end
  end

  def create_arlimtalk(user)
    unless user.is_a?(User)
      return nil
    end

    dispatched_notification_param = create_dispatched_notification_params(@message_template_id, "target_message", @job_posting.id, "yobosa", user.id, "job_detail")
    application_notification_param = create_dispatched_notification_params(@message_template_id, "target_message", @job_posting.id, "yobosa", user.id, "application")
    contact_notification_param = create_dispatched_notification_params(@message_template_id, "target_message", @job_posting.id, "yobosa", user.id, "contact_message")

    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    view_link = "#{@base_url}?lat=#{user.lat}&lng=#{user.lng}&referral=target_notification&#{utm}" + dispatched_notification_param
    application_link = "#{@base_url}/application?referral=target_notification&#{utm}" + application_notification_param
    contact_link = "#{@base_url}/contact-messages?referral=target_notification&#{utm}" + contact_notification_param

    BizmPostPayMessage.new(
      @message_template_id,
      user.phone_number,
      {
        title: @job_posting.title,
        message: generate_message_content(user),
        view_link: view_link,
        application_link: application_link,
        contact_link: contact_link,
        job_posting_id: @job_posting.id,
        job_posting_public_id: @job_posting.public_id,
        business_name: @job_posting.business.name,
        job_posting_type: @job_posting.work_type,
      },
      user.public_id,
      "AI"
    )
  end

  def generate_message_content(user)
    "#{@job_posting.title}

■ 근무지
#{@job_posting.address}

■ 예상 통근거리
#{user.simple_distance_from_ko(@job_posting)}

■ 근무시간
#{get_days_text(@job_posting)} #{get_hours_text(@job_posting)}

■ 급여
#{get_pay_text(@job_posting)}

아래 버튼을 눌러 지원하거나 일자리 정보를 자세히 확인해 보세요!"
  end
end
