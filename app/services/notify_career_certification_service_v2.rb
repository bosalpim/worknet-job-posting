# frozen_string_literal: true

class NotifyCareerCertificationServiceV2
  include JobMatchHelper
  include JobPostingsHelper

  TEMPLATE_TREATMENT_MAP = {
    'A' => MessageTemplateName::CONNECT_RESULT_USER_SURVEY_A,
    'B' => MessageTemplateName::CONNECT_RESULT_USER_SURVEY_B
  }

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @phone = params.dig(:phone)
    @user_id = params.dig(:user_id)
    @job_posting_id = params.dig(:job_posting_id)
    @user = User.find_by(public_id: @user_id)
    @job_posting = JobPosting.find_by(public_id: @job_posting_id)
    @business = @job_posting.business
    @link = params.dig(:link)
  end

  def call
    treatment = Bex::FetchTreatmentByUserIdService.new(
      experiment_key: Bex::Experiment::CAREER_CERTIFICATION,
      user_id: @user_id
    ).call

    if treatment.nil?
      Jets.logger.error "Treatment not found for user #{@user_id}"
      return
    end

    template_id = TEMPLATE_TREATMENT_MAP.fetch(
      treatment.key,
      MessageTemplateName::CONNECT_RESULT_USER_SURVEY_A
    )

    reserve_dt = (DateTime.now + 3.days).in_time_zone('Seoul').strftime('%Y%m%d%H%M%S')

    response = KakaoNotificationService.call(
      template_id: template_id,
      message_type: 'AI',
      phone: @phone,
      template_params: {
        link: @link,
        target_public_id: @user_id,
        job_posting_title: @job_posting.title,
        job_posting_address: @job_posting.address,
        job_posting_schedule: "#{get_days_text(@job_posting)} / #{get_hours_text(@job_posting)}",
        job_posting_id: @job_posting_id,
        center_name: @business.name,
        type_match: is_type_match(@user.preferred_work_types, @job_posting.work_type),
        gender_match: is_gender_match(@user.preferred_gender, @job_posting.gender),
        day_match: is_day_match(@user.job_search_days, @job_posting.working_days),
        time_match: is_time_match(work_start_time: @job_posting.work_start_time, work_end_time: @job_posting.work_end_time, job_search_times: @user.job_search_times),
        grade_match: is_grade_match(@user.preferred_grades, @job_posting.grade),
      },
      reserve_dt: Jets.env == 'production' ? reserve_dt : nil
    )

    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = ''

    code = response.dig('code')
    message = response.dig('message')

    if code == 'success' && message == 'K000'
      success_count += 1
    elsif code == 'success'
      tms_success_count += 1
    else
      fail_count += 1
      fail_reasons = response.dig("originMessage")
    end

    NotificationResult.create!({
                                 send_type: NotificationResult::CAREER_CERTIFICATION_V2,
                                 send_id: @job_posting.title,
                                 template_id: template_id,
                                 used_medium: 'kakao_arlimtalk',
                                 success_count: success_count,
                                 tms_success_count: tms_success_count,
                                 fail_count: fail_count,
                                 fail_reasons: fail_reasons
                               })
  end

end