class Notification::Factory::TargetUserResidentJobPostingService < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include TranslationHelper
  include DayHelper
  include AlimtalkMessage

  def initialize(params)
    super(MessageTemplates[MessageNames::TARGET_USER_RESIDENT_JOB_POSTING])
    @job_posting = JobPosting.find(params[:job_posting_id])
    paid_job_posting = PaidJobPostingFeature.find_by_job_posting_id(params[:job_posting_id])
    @is_free = paid_job_posting.nil? ? true : false
    @base_url = "#{Main::Application::HTTPS_CAREPARTNER_URL}"
    @base_path = "jobs/#{@job_posting.public_id}"
    @application_path = @base_path + '/application'
    @deeplink_scheme = Main::Application::DEEP_LINK_SCHEME

    radius = params[:radius].nil? ? 7000 : params[:radius]
    min_radius = params[:min_radius].nil? ? nil : params[:min_radius]
    @list = User
              .receive_job_notifications
              .selected_resident
              .within_radius(
                radius,
                @job_posting.lat,
                @job_posting.lng,
                min_radius
                ).where.not(phone_number: nil)
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

    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    referral_app = "referral=target_notification_app"
    referral_web = "referral=target_notification"

    app_view_link_query = "?lat=#{user.lat}&lng=#{user.lng}&#{referral_app}&#{utm}"
    view_link_query = "?lat=#{user.lat}&lng=#{user.lng}&#{referral_web}&#{utm}"
    app_application_link_query = "?#{referral_app}&#{utm}"
    application_link_query = "?#{referral_web}&#{utm}"

    BizmPostPayMessage.new(
      @message_template_id,
      user.phone_number,
      {
        title: @job_posting.title,
        message: generate_message_content,
        base_url: @base_url,
        deeplink_scheme: @deeplink_scheme + '/',
        app_view_link_path: @base_path + app_view_link_query,
        view_link_path: @base_path + view_link_query,
        app_application_link_path: @application_path + app_application_link_query,
        application_link_path: @application_path + application_link_query,
        job_posting_id: @job_posting.id,
        job_posting_public_id: @job_posting.public_id,
        business_name: @job_posting.business.name,
        job_posting_type: @job_posting.work_type,
        is_free: @is_free
      },
      user.public_id,
      "AI"
    )
  end
  def generate_message_content
    "#{@job_posting.title}

■ 급여 : #{get_pay_text(@job_posting)}

■ 어르신 정보 : #{create_customer_info(@job_posting.job_posting_customer)}

■ 근무 장소 : #{@job_posting.address}

■ 근무 요일(입주) : 주 #{@job_posting.working_days.count}일 근무#{vacation_day_resident(@job_posting)}

이 메세지는 일자리알림을 신청한 분에게만 발송돼요

👇'일자리 확인하기' 버튼을 누르고 자세한 정보를 확인하세요👇"
  end
end
