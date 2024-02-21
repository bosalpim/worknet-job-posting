class Notification::Factory::SearchTarget::JobPostingTargetUserService

  def self.call(lat, lng)
    new(lat, lng).call
  end

  def initialize(lat, lng)
    @lat = lat
    @lng = lng
  end

  def call

    users = User
        .receive_job_notifications
        .within_radius(
          3000,
         @lat,
         @lng
       )

    users
  end
end