class JobPosting < ApplicationRecord
  include PublicId
  include StringNumber
  include EarthDistance

  acts_as_geolocated

  set_string_number_fields :manager_phone_number

  validates :proposal_usable_count, numericality: { greater_than_or_equal_to: 0 }

  enum status: { draft: 'draft', init: 'init', closed: 'closed' }
  enum work_type: {
    commute: 'commute',
    resident: 'resident',
    bath_help: 'bath_help',
    day_care: 'day_care',
    sanatorium: 'sanatorium',
    hospital: 'hospital',
    facility: 'facility',
  }
  WORKING_DAYS = %w[monday thuesday wednesday thursday friday saturday sunday]

  enum working_hours_type: {
    normal: 'normal',
    two_shift: 'two_shift',
    three_shift: 'three_shift',
    one_shift: 'one_shift',
  }

  enum pay_type: {
    hourly: 'hourly',
    daily: 'daily',
    monthly: 'monthly',
    yearly: 'yearly',
    per_case: 'per_case',
  }

  enum grade: {
    none: 0,
    first: 1,
    second: 2,
    third: 3,
    fourth: 4,
    fifth: 5,
    sixth: 6,
  },
       _suffix: true

  WELFARES = %w[
    social_insurance
    severance_pay
    pay_for_meal
    driving_benefit
    transportation_expenses
    severe_disability_allowance
    holiday_gift
    cash_gift
    long_service_gift
    government_grants
  ]

  APPLYING_OPTIONS = %w[
    newbie
    veterant
    veterant_required
    driver_license_required
    dementia_education_required
  ]

  APPLYING_METHODS = %w[phone email visiting]

  enum applying_due_date: { one_week: 'one_week', two_weeks: 'two_weeks' }

  belongs_to :business
  belongs_to :scraped_worknet_job_posting, required: false
  belongs_to :scrape_yynr_job_posting, required: false
  has_many :care_manager_job_applications
  has_many :care_managers, through: :care_manager_job_applications
  has_one :job_posting_customer

  scope :commute_work, -> { where(work_type: %w[commute bath_help]) }
  scope :resident_work, -> { where(work_type: 'resident') }
  scope :facility_work,
        -> { where(work_type: %w[day_care sanatorium hospital facility]) }
  scope :active, -> { init.where(published_at: 2.weeks.ago..) }

  before_create :set_work_type
  before_create :set_default_values
  before_save :update_location, if: :will_save_change_to_address?
  before_save :update_closing_at, if: :will_save_change_to_applying_due_date?

  after_save :check_job_posting_customer

  def self.find_by_bounds(ne_lat:, ne_lng:, sw_lat:, sw_lng:)
    self
      .where('lat between ? and ?', sw_lat, ne_lat)
      .where('lng between ? and ?', sw_lng, ne_lng)
  end

  def update_location
    return if self.address.blank?

    location = NaverApi.coords_from_address(self.address)
    unless location.nil?
      self.lat = location[:lat]
      self.lng = location[:lng]
    end
  end

  def set_work_type
    self.work_type = determine_work_type if self.work_type.blank?
  end

  def set_default_values
    # draft 기능이 제거된 상태에서의 default value 설정
    self.status = 'init' if self.status.blank?
    self.published_at = DateTime.now if self.published_at.blank?
  end

  def update_closing_at
    base_date = self.created_at || DateTime.now

    if self.applying_due_date == 'one_week'
      self.closing_at = base_date + 1.week
    elsif self.applying_due_date == 'two_weeks'
      self.closing_at = base_date + 2.weeks
    end
  end

  def can_has_customer?
    [
      JobPosting.work_types[:commute],
      JobPosting.work_types[:resident],
      JobPosting.work_types[:bath_help],
    ].include?(self.work_type)
  end

  def check_job_posting_customer
    unless can_has_customer?
      self.job_posting_customer.destroy if self.job_posting_customer.present?
    end
  end

  def check_closed?
    return true if closed?

    if worknet_job_posting?
      if scraped_worknet_job_posting.check_closed?
        self.closed!
        return true
      end

      return false
    end

    if closing_at < DateTime.now
      self.closed!

      return true
    end

    return false
  end

  def is_closed?
    self.closed? || (closing_at.present? && (closing_at < DateTime.now))
  end

  def email
    self.manager_email || self.client&.email
  end

  def phone_number
    self.manager_phone_number || self.client&.phone_number
  end

  def worknet_job_posting?
    scraped_worknet_job_posting.present?
  end

  def determine_work_type
    # 입주
    if title.match(/입주/) || description.match(/입주/)
      return JobPosting.work_types[:resident]
    end

    # 모집직종이 시설 요양보호사인 경우
    occupation =
      scraped_worknet_job_posting
        .info
        .dig('occupation_infos')
        &.filter { |i| i['name'] == '모집직종' }
        &.first
        &.dig('value')
    if occupation&.match(/시설 요양보호사/)
      return JobPosting.work_types[:facility]
    end

    # 모집직종이 재가 요양보호사/간병인 인 경우
    if occupation&.match(/재가 요양보호사/) || occupation&.match(/재가 간병인/)
      return JobPosting.work_types[:commute]
    end

    # 모집직종이 "요양보호사 및 간병인"인 경우
    if occupation&.match(/요양 보호사 및 간병인/)
      if title.match(/(요양원|주간보호|주야간|실버타운)/)
        return JobPosting.work_types[:facility]
      end
      return JobPosting.work_types[:commute]
    end

    # 모집직종이 "운전원"인 경우
    return JobPosting.work_types[:facility] if occupation&.match(/운전원/)
  end
end
