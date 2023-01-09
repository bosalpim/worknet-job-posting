class Business < ApplicationRecord
  include StringNumber

  set_string_number_fields :phone_number, :business_number

  validates :proposal_usable_count, numericality: { greater_than_or_equal_to: 0 }

  has_many :job_postings

  validates :business_number, uniqueness: { allow_blank: true }
end
