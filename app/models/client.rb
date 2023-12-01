class Client < ApplicationRecord
  include PublicId
  include StringNumber

  set_string_number_fields :phone_number

  has_many :businesses, through: :business_clients
  has_many :job_postings
  has_many :client_push_tokens, dependent: :destroy

  def business
    self.businesses.first
  end
end
