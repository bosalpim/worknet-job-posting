class User < ApplicationRecord
  include PublicId
  include EarthDistance::ActsAsGeolocated
  include EarthDistance::QueryMethods

  DEFAULT_LAT = 37.555042
  DEFAULT_LNG = 126.9769233

  has_many :proposals, dependent: :nullify
  has_many :user_push_tokens, dependent: :destroy

  enum gender: { male: 'male', female: 'female' }

  enum preferred_distance: {
    by_walk15: 'by_walk15',
    by_walk30: 'by_walk30',
    by_km_3: 'by_km_3',
    by_km_5: 'by_km_5',
  }

  enum status: {
    draft: 'draft',
    active: 'active',
    blocked: 'blocked',
    deleted_by_user: 'deleted_by_user',
  }

  enum job_search_status: {
    actively: 0,
    commonly: 1,
    off: 2,
    working: 3,
  }

  enum reception_status: {
    acceptable: 'acceptable',
    unacceptable: 'unacceptable',
    phone_number_error: 'phone_number_error',
    sleep: 'sleep'
  }

  scope :receive_notifications, -> { where(notification_enabled: true) }
  scope :receive_job_notifications, -> { where(job_notification_enabled: true).where(has_certification: true).active }
  scope :receive_proposal_notifications, -> { where(proposal_notification_enabled: true).where(has_certification: true).active }
  scope :within_last_3_days, -> { where('last_used_at >= ?', 3.days.ago) }

  validates :address, presence: true, if: -> { self.status == 'active' }
  validates :preferred_distance,
            presence: true,
            if: -> { self.status == 'active' }
  validates :preferred_work_types,
            presence: true,
            if: -> { self.status == 'active' }
  validates :has_certification,
            inclusion: {
              in: [true, false],
            },
            if: -> { self.status == 'active' }
  validates :phone_number, presence: true, if: -> { self.status == 'active' }

  def is_sendable_app_push
    !push_token.nil?
  end

  def push_token
    self.user_push_tokens.vaild_tokens.first
  end

  def distance_from(object)
    User
      .select(
        "users.id, earth_distance(ll_to_earth(lat, lng), ll_to_earth(#{object.lat}, #{object.lng})) AS distance",
      ).find(id).distance
  end

  def distance_from_ko(object)
    distance = distance_from(object)
    if distance.present?
      if distance <= 1080
        minutes = (distance / 60).to_i
        minutes = minutes.zero? ? 1 : minutes
        "걸어서 #{minutes}분"
      else
        "약 #{(distance / 1000).to_i}km"
      end
    else
      "알수없음"
    end
  end

  def simple_distance_from_ko(object)
    distance = distance_from(object)
    if distance.present?
      if distance <= 1800
        minutes = (distance / 60).to_i
        minutes = minutes.zero? ? 1 : minutes
        "걸어서 #{minutes}분"
      else
        "걸어서 30분 이상"
      end
    end
  end

  def korean_gender
    if self.male?
      '남자'
    elsif self.female?
      '여자'
    else
      nil
    end
  end
end
