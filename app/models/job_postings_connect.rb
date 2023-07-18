class JobPostingsConnect < ApplicationRecord
  belongs_to :job_posting
  belongs_to :user

  has_one :career_certification

  validates :connect_type, presence: true
end
