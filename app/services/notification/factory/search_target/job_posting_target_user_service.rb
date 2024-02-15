class Notification::Factory::SearchTarget::JobPostingTargetUserService
  NEW_JOB_POSTING_TARGET_DISTANCE_MAP = {
    by_walk15: 1800,
    by_walk30: 3000,
    by_km_3: 5000,
    by_km_5: 5000,
  }

  def self.call(lat, lng, distance, gender)
    new(lat, lng, distance, gender).call
  end

  def initialize(lat, lng, distance, gender)
    @lat = lat
    @lng = lng
    @distance = distance
    @gender = gender
  end

  def call

    users = User
        .receive_job_notifications
        .within_radius(
         NEW_JOB_POSTING_TARGET_DISTANCE_MAP[@distance],
         @lat,
         @lng
       )
       .where(gender: @gender, has_certification: true)
       .active

    if Jets.env != 'production'
      return [User.last]
    end

    users
  end
end