class NotifySavedJobUserService
  include JobMatchHelper
  include ApplicationHelper
  include JobPostingsHelper
  include ApplicationHelper
  def self.call(list)
    new(list).call
  end

  def initialize(list)
    @list = list || []
    @messages = []
  end

  def call
    make_message

    Jets.logger.info "-------------- MESSAGE START --------------"
    @messages.each do |message|
      Jets.logger.info message
    end
    Jets.logger.info "-------------- MESSAGE END --------------"

    # send
    results = send_message(@messages, KakaoTemplate::CALL_SAVED_JOB_POSTING_V2)
    process_results(results, KakaoTemplate::CALL_SAVED_JOB_POSTING_V2)
  end

  private

  def make_message
    @list.each do |saved_job_posting|
      job_posting = saved_job_posting.job_posting
      next if job_posting.is_closed? || job_posting.worknet_job_posting?

      user_pn = saved_job_posting.user.phone_number
      client_pn = saved_job_posting.job_posting.phone_number

      check_connected = []
      # 공고 배포 이후 시간 중에서, 연결된 적이 있는지
      target_call_records = CallRecord.where("created_at > ?", job_posting.published_at)
      check_connected += target_call_records.where(to_number: user_pn, from_number: client_pn)
      check_connected += target_call_records.where(to_number: client_pn, from_number: user_pn)

      next if check_connected.count != 0

      user = saved_job_posting.user
      # 메시지 데이터 > 어르신 정보
      customer = job_posting.job_posting_customer
      customer_info = convert_safe_text("#{[customer.korean_grade, customer.korean_age, customer.korean_gender].select { |i| i.present? }.join(' / ')}")
      # 메시지 데이터 > 근무 요일
      work_schedule = convert_safe_text("#{format_consecutive_dates(job_posting)}")
      # 메시지 데이터 > 근무 장소
      distance = user.distance_from(job_posting)
      location_info = convert_safe_text("#{job_posting.address} (#{get_distance_text({
                                                                                       distance: distance
                                                                                     })})")
      # 메시지 데이터 > 급여 정보
      pay_text = convert_safe_text(get_pay_text(job_posting))

      # 이벤트 로깅 데이터 >
      user = saved_job_posting.user

      @messages.push({
                      phone_number: user.phone_number,
                      target_public_id: user.public_id,
                      tem_params: {
                        customer_info: customer_info,
                        work_schedule: work_schedule,
                        location_info: location_info,
                        pay_text: pay_text,
                        type_match: is_type_match(user.preferred_work_types, job_posting.work_type),
                        gender_match: is_gender_match(user.preferred_gender, job_posting.gender),
                        day_match: is_day_match(user.job_search_days, job_posting.working_days),
                        time_match: is_time_match(work_start_time: job_posting.work_start_time, work_end_time: job_posting.work_end_time, job_search_times: user.job_search_times),
                        grade_match: is_grade_match(user.preferred_grades, job_posting.grade),
                        job_posting_title: job_posting.title,
                        center_name: job_posting.business.name,
                        job_posting_public_id: job_posting.public_id
                      }
                    })
    end
  end
end