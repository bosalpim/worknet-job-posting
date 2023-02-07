class ExtraBenefitNotificationService
  def self.call
    new.call
  end

  def self.test_call
    new.test_call
  end

  def initialize
    @shorten_url = build_shorten_url
  end

  def call
    User.active.receive_notifications.find_each do |user|
      send_notification(user)
    end
  end

  def test_call
    send_notification(User.last)
  end

  private

  attr_reader :shorten_url

  def send_notification(user)
    radius = get_radius(user)
    job_postings = JobPosting.init.within_radius(radius, user.lat, user.lng).where(published_at: 2.weeks.ago..)
    job_postings = job_postings.where(grade: %w[first second]).or(job_postings.where(scraped_worknet_job_posting_id: nil))
    job_postings_count = job_postings.size
    return if job_postings_count.zero?
    cpt_job_postings_count = job_postings.where(scraped_worknet_job_posting_id: nil).size
    benefit_job_postings_count = job_postings.where(grade: %w[first second]).size

    response = KakaoNotificationService.call(
      template_id: KakaoTemplate::EXTRA_BENEFIT,
      phone: Jets.env == "production" ? user.phone_number : '01097912095',
      template_params: {
        distance: I18n.t("activerecord.attributes.user.preferred_distance.#{user.preferred_distance}"),
        job_postings_count: "#{job_postings_count} 건",
        cpt_job_postings_count: "#{cpt_job_postings_count} 건",
        benefit_job_postings_count: "#{benefit_job_postings_count} 건",
        user_name: user.name,
        link: "https://carepartner.kr/jobs"
      }
    )
    Jets.logger.info response
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

  def build_shorten_url
    ShortUrl.build("https://carepartner.kr/jobs?utm_source=message&utm_medium=arlimtalk&utm_campaign=extra_benefits_job").url
  end
end