class ScrapedWorknetJobPosting < ApplicationRecord
  has_one :job_posting, required: false

  enum status: { init: 'init', closed: 'closed' }

  def check_closed?
    return true if self.closed?

    return false if self.updated_at > 1.hour.ago

    host_url = 'https://www.work.go.kr'
    conn = Faraday.new(url: host_url)
    response = conn.get(self.url)
    parsed = Nokogiri::HTML.parse(response.body)

    info1 = parsed.css('div.careers-new .left div.info')[0]

    if info1.nil?
      self.closed!

      return true
    end

    self.touch
    false
  end

  def build_job_posting
    return if self.job_posting.present?
    return if self.closed?

    business = Business.find_by(worknet_id: self.info['center_id'])
    if business.blank?
      business =
        Business.create(
          worknet_id: self.info['center_id'],
          name: self.info['center_name'],
          tel_number: self.info['contact_tel'],
          phone_number: self.info['contact_tel'],
          address: self.info['center_address'],
          worker_count:
            self.info['center_worker_count'].present? &&
              self.info['center_worker_count'][/[^\d]*(\d+).*/, 1].to_i,
          )
    end

    self.create_job_posting!(
      {
        title: self.info['title'],
        address: self.info['address'],
        description: self.info['description'],
        lat: self.info['latitude'],
        lng: self.info['longitude'],
        gender: self.info['gender'],
        grade: self.info['grade'],
        published_at: self.published_at,
        status: self.status,
        business: business,
      },
      )
  end
end
