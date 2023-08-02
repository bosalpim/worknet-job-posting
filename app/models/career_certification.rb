class CareerCertification < ApplicationRecord
  include PublicId

  belongs_to :job_postings_connect
  belongs_to :user
  belongs_to :job_posting
end
