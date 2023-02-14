class ExtraBenefitNotificationService
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
    # users = test_users(users) # if Jets.env == "staging" # WARNING 바꾸면 실제 유저에게 배포됨
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
      send_type: "extra_benefit_notification",
      template_id: KakaoTemplate::EXTRA_BENEFIT,
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
    job_postings = JobPosting.init.within_radius(radius, user.lat, user.lng).where(published_at: 2.weeks.ago..)
    job_postings = job_postings.where(grade: %w[first second]).or(job_postings.where(scraped_worknet_job_posting_id: nil))
    job_postings_count = job_postings.size
    return nil if job_postings_count.zero?
    cpt_job_postings_count = job_postings.where(scraped_worknet_job_posting_id: nil).size
    benefit_job_postings_count = job_postings.where(grade: %w[first second]).size
    shorten_url = build_shorten_url(user)

    KakaoNotificationService.call(
      template_id: KakaoTemplate::EXTRA_BENEFIT,
      phone: Jets.env.development? ? '01097912095' : user.phone_number,
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

  def build_shorten_url(user)
    default_url = "https://www.carepartner.kr/jobs?utm_source=message&utm_medium=arlimtalk&utm_campaign=extra_benefits_job&workType=overtime_pay"
    default_url = default_url + "&address=" + user.address
    default_url = default_url + "&distance=" + user.preferred_distance
    ShortUrl.build(default_url)
  end

  def test_users(users)
    users.where(phone_number: %w[01097912095 01051119300 01094659404 01066121746])
  end
end