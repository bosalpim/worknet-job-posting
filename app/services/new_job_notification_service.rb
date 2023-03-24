class NewJobNotificationService
  include Translation
  include JobPostingsHelper

  DISTANCE_LIST = {
    by_walk15: 900,
    by_walk30: 1800,
    by_km_3: 3000,
    by_km_5: 5000,
  }

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
    @origin_url = "https://#{homecare_yes ? "www." : ""}carepartner.kr/jobs/#{@job_posting.public_id}?utm_source=message&utm_medium=arlimtalk&utm_campaign=#{homecare_yes ? "new_job_homecare" : "new_job_facility"}"
    @shorten_url = build_shorten_url(@origin_url)
  end

  def call
    users = []
    User.preferred_distances.each do |key, value|
      prefer_work_type =
        job_posting.work_type == 'hospital' ? 'etc' : job_posting.work_type

      if job_posting.lat.present? && job_posting.lng.present?
        users +=
          User
            .receive_notifications
            .select(
              "users.*, earth_distance(ll_to_earth(lat, lng), ll_to_earth(#{job_posting.lat}, #{job_posting.lng})) AS distance",
              )
            .within_radius(
              DISTANCE_LIST[key.to_sym],
              job_posting.lat,
              job_posting.lng
            )
            .where(preferred_distance: key)
            .where(
              'preferred_work_types::jsonb ? :type',
              type: prefer_work_type,
              )
            .where('id not in (?)', users.empty? ? [0] : users.map(&:id))
            .where(
              'has_certification = true OR expected_acquisition in (?)',
              %w[2022/05 2022/08 2022/11],
            ).limit(1)
      end
    end

    success_count = 0
    fail_count = 0
    fail_reasons = []

    users.each do |user|
      response = send_notification(user)
      response.dig("code") == "success" ? success_count += 1 : fail_count += 1
      fail_reasons.push(response.dig("originMessage")) if response.dig("message") != "K000"
    end

    KakaoNotificationResult.create!(
      send_type: "new_job_posting",
      template_id: homecare_yes ? KakaoTemplate::NEW_JOB_POSTING_VISIT : KakaoTemplate::NEW_JOB_POSTING_FACILITY,
      success_count: success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons.uniq.join(", ")
    )
  end

  def test_call
    user = User.last
    send_notification(user)
  end

  private

  attr_reader :job_posting, :work_type_ko, :job_posting_customer, :homecare_yes, :origin_url, :shorten_url

  def send_notification(user)
    KakaoNotificationService.call(
      template_id: homecare_yes ? KakaoTemplate::NEW_JOB_POSTING_VISIT : KakaoTemplate::NEW_JOB_POSTING_FACILITY,
      phone: Jets.env == "production" ? user.phone_number : '01097912095',
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
        path: shorten_url.sub("https://carepartner.kr", ""),
        job_posting_public_id: job_posting.public_id
      }
    )
  end

  def build_shorten_url(origin_url)
    ShortUrl.build(origin_url).url
  end
end