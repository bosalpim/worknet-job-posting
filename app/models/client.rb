class Client < ApplicationRecord
  include PublicId
  include StringNumber

  ACCESS_TOKEN_MAX_TIME = 2400.freeze # 40min
  REFRESH_TOKEN_MAX_TIME = (90 * 24 * 60 * 60).freeze # 90days

  set_string_number_fields :phone_number

  has_many :business_clients
  has_many :businesses, through: :business_clients
  has_many :job_postings

  has_secure_password

  validates :email, presence: true, uniqueness: true, email: true

  def business
    self.businesses.first
  end
end
