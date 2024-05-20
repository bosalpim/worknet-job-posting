class Notification::Factory::JobAdsFirstMessage < Notification::Factory::NotificationFactoryClass
  include ApplicationHelper
  include TranslationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper
  include DispatchedNotificationsHelper

  DispatchedNotificationService = Notification::Factory::DispatchedNotifications::Service
  NotificationCreateService = Notification::Factory::Notifications::Service
  def initialize(job_posting_id)
    super(MessageTemplateName::JOB_ADS_MESSAGE_FIRST)
    job_posting = JobPosting.find(job_posting_id)
    @job_posting = job_posting
    @end_point = "/jobs/#{@job_posting.public_id}"
    @list = Notification::Factory::SearchTarget::JobAdsFirstTargetService.call(job_posting)
    @dispatched_notifications_service = DispatchedNotificationService.call(@message_template_id, "job_posting", @job_posting.id, "yobosa")
    @notification_create_service = NotificationCreateService.call(@message_template_id, "급구 일자리 지금 확인해보세요!", @job_posting.title, @end_point, "yobosa")
    create_message
  end

  def create_message
    @list.each do |user|
      create_bizm_post_pay_message(user)
    end
  end

  def create_bizm_post_pay_message(user)
    job_detail_notification_param = create_dispatched_notification_params(@message_template_id, "job_posting", @job_posting.id, "yobosa", user.id, "job_detail")
    application_notification_param = create_dispatched_notification_params(@message_template_id, "job_posting", @job_posting.id, "yobosa", user.id, "application")

    base_url = carepartner_base_url
    view_endpoint = "#{@end_point}?utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}&lat=#{user.lat}&lng=#{user.lng}" + job_detail_notification_param
    origin_url = "#{base_url}#{view_endpoint}"
    shorten_url = build_shorten_url(origin_url)
    work_type_ko = translate_type('job_posting', @job_posting, :work_type)
    application_url = "#{base_url}/jobs/#{@job_posting.public_id}/application?utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}" + application_notification_param
    job_posting_customer = @job_posting.job_posting_customer
    homecare_yes = %w[commute resident bath_help].include?(@job_posting.work_type)

    params = {
      title: "구인 광고 메세지 1차",
      message: homecare_yes ? build_visit_message(user, @job_posting.title, job_posting_customer) : build_facility_message(user, @job_posting.title),
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
      origin_url: origin_url,
      application_url: application_url,
      path: shorten_url.sub("https://carepartner.kr", ""),
      job_posting_public_id: @job_posting.public_id,
      job_posting_title: @job_posting.title,
      target_public_id: user.public_id,
      last_used_under_three_day: user.last_used_at.nil? ? false : (user.last_used_at > 3.days.ago)
    }

    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, user.phone_number, params, user.public_id, 'AI'))
  end

  def build_visit_message(user, title, job_posting_customer)
    "안녕하세요.
선생님께서 등록해주신 구직 정보에 맞는 일자리 정보를 안내드립니다.

■ 공고제목
#{title}

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

아래 버튼을 눌러 사이트를 방문해 자세한 내용을 확인하고 지원해보세요!"
  end

  def build_facility_message(user, title)
    "안녕하세요.
선생님께서 등록해주신 구직 정보에 맞는 일자리 정보를 안내드립니다.

■ 공고제목
#{title}

■ 근무지
#{@job_posting.address}

■ 통근거리
#{user.simple_distance_from_ko(@job_posting)}

■ 근무시간
#{get_days_text(@job_posting)} #{get_hours_text(@job_posting)}

■ 급여
#{get_pay_text(@job_posting)}

아래 버튼을 눌러 사이트를 방문해 자세한 내용을 확인하고 지원해보세요!"
  end
end