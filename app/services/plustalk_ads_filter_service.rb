class PlustalkAdsFilterService
  def self.call
    new.call
  end

  def initialize
  end

  def call
    JobPosting
      .where('job_postings.created_at >= ?', 3.days.ago.beginning_of_day)
      .where('job_postings.created_at < ?', 2.days.ago.beginning_of_day)
      .left_joins(:paid_job_posting_features)
      .where(paid_job_posting_features: { id: nil })
      .where(scraped_worknet_job_posting_id: nil)
  end
end
