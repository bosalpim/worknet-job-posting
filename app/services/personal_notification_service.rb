class PersonalNotificationService
  def self.call
    new.call
  end

  def self.test_call
    new.test_call
  end

  def call
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []
    users = User.where(phone_number: %w[01097912095 01051119300 01094659404 01066121746])
    users = users.limit(3) if Jets.env == "development"
    users = test_users(users) if Jets.env == "staging" # WARNING 바꾸면 실제 유저에게 배포됨
    users.find_each do |user|
      begin
        response = send_notification(user)
        next if response.nil?
        if response&.dig("code") == "success"
          if response&.dig("message") == "K000"
            success_count += 1
          else
            tms_success_count += 1
          end
        else
          fail_count += 1
        end
        fail_reasons.push(response&.dig("originMessage")) if response&.dig("message") != "K000"
      rescue => e
        fail_count += 1
        fail_reasons.push(e.message)
      end
    end
    KakaoNotificationResult.create!(
      send_type: "personalized_notification",
      template_id: KakaoTemplate::PERSONALIZED,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons.uniq.join(", ")
    )
  end

  def test_call
    send_notification(User.last)
  end

  private

  def send_notification(user)
    radius = get_radius(user)
    job_postings = JobPosting.init.where(published_at: 2.weeks.ago..).within_radius(radius, user.lat, user.lng)
    job_postings_count = job_postings.size
    return if job_postings_count.zero?
    visit_job_postings_count = job_postings.where(work_type: %w[commute bath_help]).size
    resident_job_postings_count = job_postings.where(work_type: %w[resident]).size
    facility_job_postings_count = job_postings.where(work_type: %w[day_care sanatorium hospital facility]).size
    shorten_url = build_shorten_url(user)

    response = KakaoNotificationService.call(
      template_id: KakaoTemplate::PERSONALIZED,
      phone: Jets.env.development? ? '01097912095' : user.phone_number,
      template_params: {
        distance: I18n.t("activerecord.attributes.user.preferred_distance.#{user.preferred_distance}"),
        job_postings_count: job_postings_count,
        visit_job_postings_count: "#{visit_job_postings_count} 건",
        resident_job_postings_count: "#{resident_job_postings_count} 건",
        facility_job_postings_count: "#{facility_job_postings_count} 건",
        user_name: user.name,
        path: shorten_url.url.sub("https://carepartner.kr", ""),
        original_url: shorten_url.original_url
      }
    )
    response
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
      900
    end
  end

  def build_shorten_url(user)
    default_url = "https://www.carepartner.kr/jobs?utm_source=message&utm_medium=arlimtalk&utm_campaign=pesonalized_job"
    default_url = default_url + "&address=" + user.address
    default_url = default_url + "&distance=" + URI.encode(user.preferred_distance)
    ShortUrl.build(default_url)
  end

  def test_users(users)
    users.where(phone_number: %w[])
  end
end