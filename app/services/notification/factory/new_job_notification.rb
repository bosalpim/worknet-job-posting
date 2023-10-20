class Notification::Factory::NewJobNotification < Notification::Factory::NotificationFactoryClass
  include ApplicationHelper
  include TranslationHelper
  include JobPostingsHelper

  NewJobPostingUsersService = Notification::SearchUser::NewJobPostingUsersService
  def initialize(job_posting_id)
    super(MessageTemplateName::NEW_JOB_POSTING)
    job_posting = JobPosting.find(job_posting_id)
    @job_posting = job_posting
    @list = NewJobPostingUsersService.call(job_posting)
    create_message
  end
  def create_message
    @list.each do |user|
      if @target_medium == 'app_push'
        if user.is_sendable_app_push
          create_app_push_message(user)
        else
          create_bizm_post_pay_message(user)
        end
      else
        create_bizm_post_pay_message(user)
      end
    end
  end

  private

  def create_app_push_message(user)
    app_push = AppPush.new(
      @message_template_id,
      user.push_token.token,
      MessageTemplateName::NEW_JOB_POSTING,
      {
        body: '새로운 일자리가 나타났습니다.',
        title: '신규 일자리 등장',
        link: 'carepartner://app/jobs/recently_published'
      },
      user.public_id,
      )
    @app_push_list.push(app_push)
  end

  def create_bizm_pre_pay_message
    base_url = "https://www.carepartner.kr"
    view_endpoint = "/jobs/recently_published?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_posting&lat=#{user.lat}&lng=#{user.lng}"
    origin_url = "#{base_url}#{view_endpoint}"
    mute_endpoint = "/me/notification/off?type=job&utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_posting"
    mute_url = "#{base_url}#{mute_endpoint}"
    shorten_url = build_shorten_url(origin_url)
    work_type_ko = translate_type('job_posting', @job_posting, :work_type)
    job_posting_customer = @job_posting.job_posting_customer
    homecare_yes = %w[commute resident bath_help].include?(@job_posting.work_type)

    params = {
      title: "신규일자리 알림",
      message: homecare_yes ? build_visit_message(origin_url, user, job_posting_customer) : build_facility_message(origin_url, user),
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

    @bizm_pre_pay_list.push(BizmPrePayMessage.new(@message_template_id, 'AT', user.phone_number, params, user.public_id))
  end

  def build_visit_message(url, user, job_posting_customer)
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
자세한 내용을 확인하고 지원해보세요!
#{build_shorten_url(url)}"
  end

  def build_facility_message(url, user)
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
자세한 내용을 확인하고 지원해보세요!
#{build_shorten_url(url)}"
  end
end