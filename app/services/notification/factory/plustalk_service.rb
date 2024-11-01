# frozen_string_literal: true

class Notification::Factory::PlustalkService < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include DispatchedNotificationsHelper
  include AlimtalkMessage

  DispatchedNotificationService = Notification::Factory::DispatchedNotifications::Service

  def initialize(params)
    super(MessageTemplates::TEMPLATES[MessageNames::TARGET_USER_JOB_POSTING])
    @job_posting = JobPosting.find(params[:job_posting_id])
    paid_job_posting = PaidJobPostingFeature.find_by_job_posting_id(params[:job_posting_id])
    @is_free = paid_job_posting.nil? ? true : false
    @base_url = "#{Main::Application::CAREPARTNER_URL}jobs/#{@job_posting.public_id}"
    @deeplink_scheme = Main::Application::DEEP_LINK_SCHEME
    begin
      @radius = if params[:radius]
                  Integer(params[:radius])
                else
                  @job_posting.is_facility? ? 5000 : 3000
                end
    rescue ArgumentError, TypeError
      @radius = @job_posting.is_facility? ? 5000 : 3000
    end
    min_radius = params[:min_radius].nil? ? nil : params[:min_radius]
    count = params[:count].nil? ? nil : params[:count]
    @list = User
              .receive_job_notifications
              .within_radius(
                @radius,
                @job_posting.lat,
                @job_posting.lng,
                min_radius
              ).where.not(phone_number: nil)
              .order(Arel.sql("earth_distance(ll_to_earth(#{@job_posting.lat}, #{@job_posting.lng}), ll_to_earth(users.lat, users.lng)) ASC"))
              .limit(count)

    @dispatched_notifications_service = DispatchedNotificationService.call(@message_template_id, "plustalk", @job_posting.id, "yobosa")
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

    dispatched_notification_param = create_dispatched_notification_params(@message_template_id, "plustalk", @job_posting.id, "yobosa", user.id, "job_detail")
    application_notification_param = create_dispatched_notification_params(@message_template_id, "plustalk", @job_posting.id, "yobosa", user.id, "application")
    contact_notification_param = create_dispatched_notification_params(@message_template_id, "plustalk", @job_posting.id, "yobosa", user.id, "contact_message")

    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    view_link = "#{@base_url}?lat=#{user.lat}&lng=#{user.lng}&referral=target_notification&#{utm}" + dispatched_notification_param
    application_link = "#{@base_url}/application?referral=target_notification&#{utm}" + application_notification_param
    contact_link = "#{@base_url}/contact-messages?referral=target_notification&#{utm}" + contact_notification_param
    share_link = "#{@base_url}/share?#{utm}"

    BizmPostPayMessage.new(
      @message_template_id,
      user.phone_number,
      {
        title: @job_posting.title,
        message: generate_message_content(user),
        view_link: view_link,
        application_link: application_link,
        contact_link: contact_link,
        share_link: share_link,
        job_posting_id: @job_posting.id,
        job_posting_public_id: @job_posting.public_id,
        business_name: @job_posting.business.name,
        job_posting_type: @job_posting.work_type,
        is_free: @is_free
      },
      user.public_id,
      "AI",
      nil,
      [0]
    )
  end

  def generate_message_content(user)
    "#{@job_posting.title}

■ 급여: #{get_pay_text(@job_posting)}

■ 근무 장소: #{@job_posting.address}
- #{user.simple_distance_from_ko(@job_posting)}

■ 근무 시간: #{get_days_text(@job_posting)} #{get_hours_text(@job_posting)}

■ 어르신 정보: #{@job_posting.job_posting_customer ? create_customer_info(@job_posting.job_posting_customer) : ""}

이 메세지는 일자리알림을 신청한 분에게만 발송돼요

👇'일자리 확인하기' 버튼을 누르고 자세한 정보를 확인하세요👇"
  end
end
