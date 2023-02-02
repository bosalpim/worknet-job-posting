class NewJobNotificationService
  include Translation
  include JobPostingsHelper

  def self.call(job_posting_id)
    new(job_posting_id).call
  end

  def initialize(job_posting_id)
    @job_posting = build_job_posting(job_posting_id)
  end

  def call
    # 반경 5km 설정한 요양보호사 발송
    users_5km = User.within_radius(5_000, job_posting.lat, job_posting.lng)
    users_5km = users_5km.by_km_5
    users_5km.find_each do |user|
      send_notification(user)
    end

    # 반경 3km 설정한 요양보호사 발송
    users_3km = User.within_radius(3_000, job_posting.lat, job_posting.lng)
    users_3km = users_3km.by_km_3.where.not(id: users_5km.ids)
    users_3km.find_each do |user|
      send_notification(user)
    end

    # 30분 거리 설정한 요양보호사 발송
    users_30_min = User.within_radius(1_800, job_posting.lat, job_posting.lng)
    users_30_min = users_30_min.by_walk30.where.not(id: [*users_5km.ids, *users_3km.ids])
    users_30_min.find_each do |user|
      send_notification(user)
    end

    # 15분 거리 설정한 요양보호사
    users_15_min = User.within_radius(900, job_posting.lat, job_posting.lng)
    users_15_min = users_15_min.by_walk15.where.not(id: [*users_5km.ids, *users_3km.ids, *users_30_min.ids])
    users_15_min.find_each do |user|
      send_notification(user)
    end
  end

  private

  attr_reader :job_posting_id

  def send_notification(user)
    work_type_ko = translate_type('job_posting', job_posting, :work_type)
    job_posting_customer = job_posting.job_posting_customer

    KakaoNotificationService.call(
      template_id: KakaoTemplate::NEW_JOB_POSTING,
      phone: '01097912095',
      template_params: {
        title: "[#{translate_type('job_posting_customer', job_posting_customer, :grade) || '등급없음'}/#{calculate_korean_age(job_posting_customer&.age) || '미상의연'}세/#{translate_type('job_posting_customer', job_posting_customer, :gender) || '성별미상'}] #{work_type_ko}",
        address: job_posting.address,
        days_text: get_days_text(job_posting),
        hours_text: get_hours_text(job_posting),
        pay_text: get_pay_text(job_posting),
        meal_assistances: translate_type('job_posting_customer', job_posting_customer, :meal_assistances),
        excretion_assistances: translate_type('job_posting_customer', job_posting_customer, :excretion_assistances),
        movement_assistances: translate_type('job_posting_customer', job_posting_customer, :movement_assistances),
        housework_assistances: translate_type('job_posting_customer', job_posting_customer, :housework_assistances),
        user_name: user.name, # none
        distance: user.distance_from_ko(job_posting), # none
        job_posting_public_id: job_posting.public_id
      }
    )
  end

  def build_job_posting(job_posting_id)
    JobPosting.find(job_posting_id)
  end
end