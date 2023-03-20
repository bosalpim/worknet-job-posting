class ExtraBenefitNotificationService < PercentUserNotificationService
  attr_reader :send_type, :template_id

  def initialize(should_send_percent, sent_percent)
    super(
      should_send_percent,
      sent_percent,
      KakaoNotificationResult::EXTRA_BENEFIT,
      KakaoTemplate::EXTRA_BENEFIT
    )
  end

  def self.call(should_send_percent, sent_percent)
    new(should_send_percent, sent_percent).call
  end

  def self.test_call
    new.test_call
  end

  def call
    percent_call { |user| send_notification(user) }
  end

  def test_call
    send_notification(User.last)
  end

  private

  def send_notification(user)
    radius = get_radius(user)
    job_postings = JobPosting.init.where(published_at: 2.weeks.ago..).within_radius(radius, user.lat, user.lng)
    job_postings = get_gender_filtered_job_postings(job_postings, user)
    job_postings = job_postings.where(grade: %w[first second]).or(job_postings.where(scraped_worknet_job_posting_id: nil))
    job_postings_count = job_postings.size
    return nil if job_postings_count.zero?
    cpt_job_postings_count = job_postings.where(scraped_worknet_job_posting_id: nil).size
    benefit_job_postings_count = job_postings.where(grade: %w[first second]).size
    shorten_url = build_shorten_url(user)

    KakaoNotificationService.call(
      template_id: template_id,
      phone: Jets.env != 'production' ? '01094659404' : user.phone_number,
      template_params: {
        distance: I18n.t("activerecord.attributes.user.preferred_distance.#{user.preferred_distance}"),
        job_postings_count: "#{job_postings_count} 건",
        cpt_job_postings_count: "#{cpt_job_postings_count} 건",
        benefit_job_postings_count: "#{benefit_job_postings_count} 건",
        user_name: user.name,
        original_url: shorten_url.original_url,
        path: shorten_url.url.sub("https://carepartner.kr", "")
      }
    )
  end

  def get_radius(user)
    case user.preferred_distance
    when 'by_walk15'
      900
    when 'by_walk30'
      1800
    when 'by_km_3'
      3000
    when 'by_km_5'
      5000
    else
      1500
    end
  end

  def get_gender_filtered_job_postings(job_postings, user)
    result_job_postings = job_postings
    if user.gender == 'male'
      result_job_postings = job_postings.where(gender: ['male', nil])
    elsif user.gender == 'female'
      result_job_postings = job_postings.where(gender: ['female', nil])
    end
    result_job_postings
  end

  def build_shorten_url(user)
    default_url = "https://www.carepartner.kr/jobs?utm_source=message&utm_medium=arlimtalk&utm_campaign=extra_benefits_job&workType=overtime_pay"
    default_url = default_url + "&address=" + URI::DEFAULT_PARSER.escape(user.address)
    default_url = default_url + "&distance=" + user.preferred_distance
    ShortUrl.build(default_url)
  end
end