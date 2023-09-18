# frozen_string_literal: true

class JobPosting::CloseExpiredJobPostingsService

  def self.call(date = DateTime.now)
    new(date).call
  end

  def initialize(date = DateTime.now)
    @date = date
  end

  def call
    job_postings = JobPosting
                     .where(status: 'init')
                     .where(scraped_worknet_job_posting_id: nil)
                     .where('closing_at < ?', @date)
                     .update_all(status: 'closed')
    job_postings
  end
end
