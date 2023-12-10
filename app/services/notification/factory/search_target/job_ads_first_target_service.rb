class Notification::Factory::SearchTarget::JobAdsFirstTargetService
  DISTANCE_LIST = {
    by_walk15: 900,
    by_walk30: 1800,
    by_km_3: 3000,
    by_km_5: 5000,
  }

  def self.call(job_posting)
    new(job_posting).call
  end

  def initialize(job_posting)
    @job_posting = job_posting
  end

  def call
    users = []
    if Jets.env != 'production'
      return [User.last]
    end

    User.preferred_distances.each do |key, value|
      prefer_work_type =
        @job_posting.work_type == 'hospital' ? 'etc' : @job_posting.work_type

      if @job_posting.lat.present? && @job_posting.lng.present?
        users += User
                   .within_last_3_days
                   .receive_job_notifications
                   .select(
                     "users.*, earth_distance(ll_to_earth(lat, lng), ll_to_earth(#{@job_posting.lat}, #{@job_posting.lng})) AS distance",
                     )
                   .within_radius(
                     DISTANCE_LIST[key.to_sym],
                     @job_posting.lat,
                     @job_posting.lng
                   )
                   .where(preferred_distance: key)
                   .where(
                     'preferred_work_types::jsonb ? :type',
                     type: prefer_work_type,
                     )
                   .where('id not in (?)', users.empty? ? [0] : users.map(&:id))
                   .where(
                     'has_certification = true OR expected_acquisition in (?)',
                     %w[2022/05 2022/08 2022/11 2023/02],
                     )
                   .active
      end
    end

    users
  end
end