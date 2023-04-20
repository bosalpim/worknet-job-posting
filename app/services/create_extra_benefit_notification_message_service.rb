class CreateExtraBenefitNotificationMessageService < CreateScheduledMessageService
  def initialize
    super(
      KakaoTemplate::EXTRA_BENEFIT,
      KakaoNotificationResult::EXTRA_BENEFIT
    )
  end

  def self.call
    new.call
  end

  def self.test_call
    new.test_call
  end

  def test_call
    data = create_message(User.where(phone_number: '01094659404').first!)
    return if data.nil?

    message = ScheduledMessage.create!(
      template_id: @template_id,
      send_type: @send_type,
      content: data.dig(:jsonb),
      phone_number: data.dig(:phone_number),
      scheduled_date: data.dig(:scheduled_date)
    )
    KakaoNotificationService.call(
      template_id: message.template_id,
      phone: Jets.env != 'production' ? '01094659404' : message.phone_number,
      template_params: JSON.parse(message.content)
    )
  end

  def call
    save_call { |user| create_message(user) }
  end

  def create_message(user)
    radius = get_radius(user)
    job_postings = JobPosting.init.where(published_at: 2.weeks.ago..).within_radius(radius, user.lat, user.lng)
    job_postings = get_gender_filtered_job_postings(job_postings, user)
    job_postings = job_postings.where(grade: %w[first second]).or(job_postings.where(scraped_worknet_job_posting_id: nil))
    job_postings_count = job_postings.size
    return nil if job_postings_count.zero?
    cpt_job_postings_count = job_postings.where(scraped_worknet_job_posting_id: nil).size
    benefit_job_postings_count = job_postings.where(grade: %w[first second]).size
    shorten_url = build_shorten_url(user)

    phone_number = user.phone_number
    jsonb = {
      distance: I18n.t("activerecord.attributes.user.preferred_distance.#{user.preferred_distance}"),
      job_postings_count: "#{job_postings_count} 건",
      cpt_job_postings_count: "#{cpt_job_postings_count} 건",
      benefit_job_postings_count: "#{benefit_job_postings_count} 건",
      user_name: user.name,
      original_url: shorten_url.original_url,
      path: shorten_url.url.sub("https://carepartner.kr", "")
    }.to_json

    return {
      phone_number: phone_number,
      jsonb: jsonb,
      scheduled_date: DateTime.now
    }
  end

  def build_shorten_url(user)
    default_url = "https://www.carepartner.kr/jobs?utm_source=message&utm_medium=arlimtalk&utm_campaign=extra_benefits_job&workType=overtime_pay"
    default_url = default_url + "&address=" + URI::DEFAULT_PARSER.escape(user.address)
    default_url = default_url + "&distance=" + user.preferred_distance
    ShortUrl.build(default_url)
  end
end