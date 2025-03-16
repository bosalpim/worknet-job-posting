# frozen_string_literal: true

class Notification::Factory::TargetUserJobPostingService < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include DispatchedNotificationsHelper
  include AlimtalkMessage

  DispatchedNotificationService = Notification::Factory::DispatchedNotifications::Service
  BexService = Bex::FetchTreatmentByUserIdService

  def initialize(params)
    super(MessageTemplates::TEMPLATES[MessageNames::TARGET_USER_JOB_POSTING])
    @job_posting = JobPosting.find(params[:job_posting_id])
    paid_job_posting = PaidJobPostingFeature.find_by_job_posting_id(params[:job_posting_id])
    @is_free = paid_job_posting.nil? ? true : false
    @base_url = "#{Main::Application::HTTPS_CAREPARTNER_URL}"
    @base_path = "jobs/#{@job_posting.public_id}"
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

    if !@is_free
      @list = User
        .receive_job_notifications
        .within_radius(
          @radius,
          @job_posting.lat,
          @job_posting.lng,
          min_radius
        ).where.not(phone_number: nil)
    else
      @list = User
        .receive_job_notifications
        .within_radius(
          3000,
          @job_posting.lat,
          @job_posting.lng,
          0
        ).where.not(phone_number: nil)
        .order("RANDOM()")
        .limit(20)
    end

    @dispatched_notifications_service = DispatchedNotificationService.call(@message_template_id, "target_message", @job_posting.id, "yobosa")
    create_message
  end

  def create_message
    @list.each do |user|
      Jets.logger.info user.public_id + user.name + user.phone_number
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

    push_token_app_version = user.push_token.nil? ? nil : user.push_token.app_version
    # 유저가 푸쉬토큰이 없어 -> 기존 알림톡
    if push_token_app_version.nil?
      return create_arlimtalk_content(false, user, nil)
    end
    # 유저가 푸쉬토큰이 있지만, 타켓 앱버전이 아니야 -> 기존 알림톡
    is_target_app_version = push_token_app_version.nil? ? false : push_token_app_version == "2.2.3"
    unless is_target_app_version
      return create_arlimtalk_content(false, user,nil)
    end

    treatment = BexService.new(experiment_key: Bex::Experiment::TARGET_JOB_POSTING_WITH_APP_LINK, user_id: user.public_id).call
    Jets.logger.info "treatment"
    Jets.logger.info treatment.key
    if treatment.key == "B"
      create_arlimtalk_content(true, user, treatment.key)
    else
      create_arlimtalk_content(false, user, treatment.key)
    end
  end

  def create_arlimtalk_content(use_detail_button_app_link, user, target_job_posting_with_app_link_treatment_key = nil)
    message_template_id = use_detail_button_app_link ? MessageNames::TARGET_USER_JOB_POSTING_WITH_APP_LINK : @message_template_id
    dispatched_notification_param = create_dispatched_notification_params(@message_template_id, "target_message", @job_posting.id, "yobosa", user.id, "job_detail")

    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{message_template_id}"
    app_view_link_query = "?lat=#{user.lat}&lng=#{user.lng}&referral=target_notification_app&#{utm}" + dispatched_notification_param
    view_link_query = "?lat=#{user.lat}&lng=#{user.lng}&referral=target_notification&#{utm}" + dispatched_notification_param
    share_link_path = "/share?#{utm}"
    message = generate_message_eclipse_content

    BizmPostPayMessage.new(
      message_template_id,
      user.phone_number,
      {
        title: @job_posting.title,
        message: message,
        base_url: @base_url,
        app_view_link_path: @base_path + app_view_link_query,
        view_link_path: @base_path + view_link_query,
        share_link_path: @base_path + share_link_path,
        job_posting_id: @job_posting.id,
        job_posting_public_id: @job_posting.public_id,
        business_name: @job_posting.business.name,
        job_posting_type: @job_posting.work_type,
        is_free: @is_free,
        experiment: target_job_posting_with_app_link_treatment_key.present? ? {
          exp_jobposting_noti_landing_App: target_job_posting_with_app_link_treatment_key,
        } : nil
      },
      user.public_id,
      "AI",
      nil,
      [0]
    )
  end

  def generate_message_eclipse_content
    short_address = truncate_address(@job_posting.address)
    pay_type_text =
      I18n.t("activerecord.attributes.job_posting.pay_type.#{@job_posting.pay_type}")

    "#{@job_posting.title}

■ 근무 시간: #{get_days_text(@job_posting)} #{get_hours_text(@job_posting)}
■ 급여: #{pay_type_text} ???원
■ 근무 장소: #{short_address}\n - 걸어서 ??분

상세한 내용과 센터 전화번호를 확인하려면
👇'일자리 확인하기' 버튼을 누르세요👇"
  end

  def truncate_address(address)
    parts = address.to_s.split(' ')
    if parts.size > 3
      parts.first(3).join(' ') + ' ???'
    else
      address
    end
  end
end
