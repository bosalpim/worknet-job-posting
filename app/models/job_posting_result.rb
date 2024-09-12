class JobPostingResult < ApplicationRecord
  belongs_to :job_posting
  belongs_to :job_postings_connect
  belongs_to :user
end
