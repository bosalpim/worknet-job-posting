class JobPostingsController < ApplicationController
  include Translation
  include JobPostingsHelper

  def create
    GetWorknetJobService.call
  end

  def new_notification
    job_posting = JobPosting.find(params[:id])
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

  def tmp
    user = User.first
    business = Business.first
    job_posting = JobPosting.last
    work_type_ko = translate_type('job_posting', job_posting, :work_type)

    KakaoNotificationService.call(
      template_id: KakaoTemplate::PROPOSAL,
      phone: '01097912095',
      template_params: {
        user_name: user.name,
        business_name: business.name,
        business_vn: job_posting.vn || business.phone_number,
        work_type_ko: work_type_ko,
        address: job_posting.address,
        distance: user.distance_from_ko(job_posting),
        pay_text: get_pay_text(job_posting),
        job_posting_public_id: ""
      }
    )
  end
end
