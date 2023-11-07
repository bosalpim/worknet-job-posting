class JobApplication < ApplicationRecord
  belongs_to :user
  belongs_to :job_posting
  belongs_to :virtual_number
end
