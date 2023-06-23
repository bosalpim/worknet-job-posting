class JobPostingsConnect < ApplicationRecord
  belongs_to :job_posting
  belongs_to :user

  validates :connect_type, presence: true
end
