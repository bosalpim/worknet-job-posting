class TargetAdAfterPostingSubjectFilterService
  def self.filter
    JobPosting
      .where('created_at >= ?', 3.days.ago.beginning_of_day)
      .where('created_at < ?', 2.days.ago.beginning_of_day)
      .left_joins(:paid_job_posting_features)
      .where(paid_job_posting_features: { id: nil })
  end
end
