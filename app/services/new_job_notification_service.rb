class NewJobNotificationService
  include Translation
  include JobPostingsHelper

  def self.call(job_posting)
    new(job_posting).call
  end

  def self.test_call(job_posting)
    new(job_posting).test_call
  end

  def initialize(job_posting)
    @job_posting = job_posting
    @work_type_ko = translate_type('job_posting', @job_posting, :work_type)
    @job_posting_customer = @job_posting.job_posting_customer
    @homecare_yes = %w[commute resident bath_help].include?(@job_posting.work_type)
    @origin_url = "https://carepartner.kr/jobs/#{@job_posting.public_id}?utm_source=message&utm_medium=arlimtalk&utm_campaign=#{homecare_yes ? "new_job_homecare" : "new_job_facility"}"
    @shorten_url = build_shorten_url(@origin_url)
  end

  def call
    # 반경 5km 설정한 요양보호사 발송
    users_5km = User.within_radius(5_000, job_posting.lat, job_posting.lng)
    users_5km = users_5km.by_km_5
    users_5km.find_each do |user|
      send_notification(user)
    end

    # 반경 3km 설정한 요양보호사 발송
    users_3km = User.within_radius(3_000, job_posting.lat, job_posting.lng)
    users_3km = users_3km.by_km_3
    users_3km.find_each do |user|
      send_notification(user)
    end

    # 30분 거리 설정한 요양보호사 발송
    users_30_min = User.within_radius(1_800, job_posting.lat, job_posting.lng)
    users_30_min = users_30_min.by_walk30
    users_30_min.find_each do |user|
      send_notification(user)
    end

    # 15분 거리 설정한 요양보호사
    users_15_min = User.within_radius(900, job_posting.lat, job_posting.lng)
    users_15_min = users_15_min.by_walk15
    users_15_min.find_each do |user|
      send_notification(user)
    end
  end

  def test_call
    user = User.find_by(public_id: "wcrfdca4ul")
    send_notification(user)
  end

  private

  attr_reader :job_posting, :work_type_ko, :job_posting_customer, :homecare_yes, :origin_url, :shorten_url

  def send_notification(user)
    KakaoNotificationService.call(
      template_id: homecare_yes ? KakaoTemplate::NEW_JOB_POSTING_VISIT : KakaoTemplate::NEW_JOB_POSTING_FACILITY,
      phone: Jets.env == "production" ? user.phone : '01097912095',
      template_params: {
        title: homecare_yes ? "[#{translate_type('job_posting_customer', job_posting_customer, :grade) || '등급없음'}/#{calculate_korean_age(job_posting_customer&.age) || '미상의연'}세/#{translate_type('job_posting_customer', job_posting_customer, :gender) || '성별미상'}] #{work_type_ko}" : "[#{work_type_ko}] 요양보호사 구인",
        work_type_ko: work_type_ko,
        address: job_posting.address,
        days_text: get_days_text(job_posting),
        hours_text: get_hours_text(job_posting),
        pay_text: get_pay_text(job_posting),
        meal_assistances: translate_type('job_posting_customer', job_posting_customer, :meal_assistances),
        excretion_assistances: translate_type('job_posting_customer', job_posting_customer, :excretion_assistances),
        movement_assistances: translate_type('job_posting_customer', job_posting_customer, :movement_assistances),
        housework_assistances: translate_type('job_posting_customer', job_posting_customer, :housework_assistances),
        welfare: get_welfare_text(job_posting),
        business_name: job_posting.business.name,
        user_name: user.name,
        distance: user.simple_distance_from_ko(job_posting),
        origin_url: origin_url,
        shorten_url: shorten_url,
        job_posting_public_id: job_posting.public_id
      }
    )
  end

  def build_shorten_url(origin_url)
    ShortUrl.build(origin_url).url
  end
end