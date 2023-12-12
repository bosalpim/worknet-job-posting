class Notification::Factory::NewJobNotification < Notification::Factory::NotificationFactoryClass
  include ApplicationHelper
  include TranslationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper
  include DispatchedNotificationsHelper

  NewJobPostingUsersService = Notification::Factory::SearchTarget::NewJobPostingUsersService
  DispatchedNotificationService = Notification::Factory::DispatchedNotifications::Service
  def initialize(job_posting_id)
    super(MessageTemplateName::NEW_JOB_POSTING)
    job_posting = JobPosting.find(job_posting_id)
    @job_posting = job_posting
    @list = NewJobPostingUsersService.call(job_posting)
    create_message
  end
  def create_message
    @list.each do |user|
      dispatched_notification_param = create_dispatched_notification_params(@message_template_id, "job_posting", @job_posting.id, "yobosa", user.id, "job_detail")
      if @target_medium == APP_PUSH
        if user.is_sendable_app_push
          create_app_push_message(user, dispatched_notification_param)
        else
          create_bizm_post_pay_message(user, dispatched_notification_param)
        end
      else
        create_bizm_post_pay_message(user, dispatched_notification_param)
      end
    end
  end

  private

  def create_app_push_message(user, dispatched_notification_param)
    work_type_ko = translate_type('job_posting', @job_posting, :work_type)

    app_push = AppPush.new(
      @message_template_id,
      user.push_token.token,
      nil,
      {
        body: "#{@job_posting.title}",
        title: '놓치면 곧 마감되는 신규 일자리가 있어요!',
        link: "#{DEEP_LINK_SCEHEME}/jobs/#{@job_posting.public_id}?utm_source=message&utm_medium=app-push&utm_campaign=new_job_posting" + dispatched_notification_param,
      },
      user.public_id,
      {
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_USER,
        "template" => @message_template_id,
        "job_posting_public_id" => @job_posting.public_id,
        "job_posting_title" => @job_posting.title,
        "job_posting_type" => work_type_ko,
        "business_name" => @job_posting.business.name,
        "send_at" => Time.current + (9 * 60 * 60),
        "type" => NOTIFICATION_TYPE_APP_PUSH
      })
    @app_push_list.push(app_push)
  end

  def create_bizm_post_pay_message(user, dispatched_notification_param)
    base_url = "https://www.carepartner.kr"
    view_endpoint = "/jobs/#{@job_posting.public_id}?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_posting&lat=#{user.lat}&lng=#{user.lng}" + dispatched_notification_param
    origin_url = "#{base_url}#{view_endpoint}"
    mute_endpoint = "/me/notification/off?type=job&utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_posting"
    mute_url = "#{base_url}#{mute_endpoint}"
    shorten_url = build_shorten_url(origin_url)
    work_type_ko = translate_type('job_posting', @job_posting, :work_type)
    job_posting_customer = @job_posting.job_posting_customer
    homecare_yes = %w[commute resident bath_help].include?(@job_posting.work_type)

    params = {
      title: "신규일자리 알림",
      message: homecare_yes ? build_visit_message(user, job_posting_customer) : build_facility_message(user),
      work_type_ko: work_type_ko,
      address: @job_posting.address,
      days_text: get_days_text(@job_posting),
      hours_text: get_hours_text(@job_posting),
      customer_grade: translate_type('job_posting_customer', job_posting_customer, :grade) || '등급없음',
      customer_age: calculate_korean_age(job_posting_customer&.age) || '미상의연',
      customer_gender: translate_type('job_posting_customer', job_posting_customer, :gender) || '성별미상',
      business_vn: @job_posting.vn,
      pay_text: get_pay_text(@job_posting),
      welfare: get_welfare_text(@job_posting),
      business_name: @job_posting.business.name,
      user_name: user.name,
      distance: user.simple_distance_from_ko(@job_posting),
      postfix_url: view_endpoint,
      mute_url: mute_url,
      origin_url: origin_url,
      path: shorten_url.sub("https://carepartner.kr", ""),
      job_posting_public_id: @job_posting.public_id,
      job_posting_title: @job_posting.title,
      target_public_id: user.public_id
    }

    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, user.phone_number, params, user.public_id, 'AT'))
  end

  def build_visit_message(user, job_posting_customer)
    "신규 일자리 알림
■ 어르신 정보
#{job_posting_customer.korean_summary}
■ 근무지
#{@job_posting.address}
■ 통근거리
#{user.simple_distance_from_ko(@job_posting)}
■ 근무시간
#{get_days_text(@job_posting)} #{get_hours_text(@job_posting)}
■ 급여
#{get_pay_text(@job_posting)}
자세한 내용을 확인하고 지원해보세요!"
  end

  def build_facility_message(user)
    work_type_ko = translate_type('job_posting', @job_posting, :work_type)

    "신규 일자리 알림
■ 근무유형
#{work_type_ko}
■ 근무지
#{@job_posting.address}
■ 통근거리
#{user.simple_distance_from_ko(@job_posting)}
■ 근무시간
#{get_days_text(@job_posting)} #{get_hours_text(@job_posting)}
■ 급여
#{get_pay_text(@job_posting)}
자세한 내용을 확인하고 지원해보세요!"
  end
end