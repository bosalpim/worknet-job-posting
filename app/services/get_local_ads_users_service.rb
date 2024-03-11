class GetLocalAdsUsersService
  def self.call
    new.call
  end

  def call
    JobPosting.joins(:paid_job_posting_features)
              .where(paid_job_posting_features: { feature: %w[target-notification target-notification-2] })
              .not_closed
  end
end