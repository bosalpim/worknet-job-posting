class Notification::Factory::SearchTarget::JobPostingTargetMessageService
  NEW_JOB_POSTING_TARGET_DISTANCE_MAP = {
    by_walk15: 1800,
    by_walk30: 3000,
    by_km_3: 5000,
    by_km_5: 5000,
  }

  def self.call(job_posting, distance, gender)
    new(job_posting, distance, gender).call
  end

  def initialize(job_posting, distance, gender)
    @job_posting = job_posting
    @distance = distance
    @gender = gender
  end

  def call
    unless @job_posting.lat.present? && @job_posting.lng.present?
      return []
    end

    users = User.preferred_distances
        .receive_job_notifications
        .select(
         "users.*, earth_distance(ll_to_earth(lat, lng), ll_to_earth(#{@job_posting.lat}, #{@job_posting.lng})) AS distance",
         )
        .within_radius(
         NEW_JOB_POSTING_TARGET_DISTANCE_MAP[@distance],
         @job_posting.lat,
         @job_posting.lng
       )
       .where(gender: @gender, has_certification: true)
       .active

    if Jets.env != 'production'
      return [User.last]
    end

    users
  end
end