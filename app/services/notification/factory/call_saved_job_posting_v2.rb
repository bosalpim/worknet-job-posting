class Notification::Factory::CallSavedJobPostingV2 < Notification::Factory::MessageFactoryClass
  include JobMatchHelper
  include ApplicationHelper
  include JobPostingsHelper

  def initialize
    super(MessageTemplate::CALL_SAVED_JOB_POSTING_V2)
    @list = SearchUserSavedJobPostingsService.call(1)
    create_message
  end

  def create_message
    @list.each do |saved_job_posting|
      job_posting = saved_job_posting.job_posting
      # next if job_posting.is_closed? || job_posting.worknet_job_posting?

      user_pn = saved_job_posting.user.phone_number
      client_pn = saved_job_posting.job_posting.phone_number

      check_connected = []
      # 공고 배포 이후 시간 중에서, 연결된 적이 있는지
      target_call_records = CallRecord.where("created_at > ?", job_posting.published_at)
      check_connected += target_call_records.where(to_number: user_pn, from_number: client_pn)
      check_connected += target_call_records.where(to_number: client_pn, from_number: user_pn)
      next if check_connected.count != 0

      Jets.logger.info "-------------- INFO START --------------\n"
      customer = job_posting.job_posting_customer
      user = saved_job_posting.user

      next unless user.notification_enabled

      # 디버깅 로그
      Jets.logger.info "공고 : #{job_posting.public_id} #{job_posting.title}\n"
      Jets.logger.info "요보사 : #{user.id} #{user.phone_number}\n"
      Jets.logger.info "-------------- INFO END --------------\n"

      # 메시지 데이터 > 어르신 정보
      customer_info = customer.nil? ? '해당없음' : convert_safe_text("#{[customer&.korean_grade, customer&.korean_age, customer&.korean_gender].select { |i| i.present? }.join(' / ')}")
      # 메시지 데이터 > 근무 요일
      work_schedule = convert_safe_text("#{format_consecutive_dates(job_posting)}")
      # 메시지 데이터 > 근무 장소
      distance = user.distance_from(job_posting)
      location_info = convert_safe_text("#{job_posting.address} (#{get_distance_text({
                                                                                       distance: distance })})")
      # 메시지 데이터 > 급여 정보
      pay_text = convert_safe_text(get_pay_text(job_posting))
      user = saved_job_posting.user

      # 여기부터 DB로 메세지 매체 관리하는 것을 추가한다.
      # if user.is_sendable_app_push
      #   app_push = AppPush.new(
      #     @message_template_id,
      #     user.push_token.token,
      #     MessageTemplate::CALL_SAVED_JOB_POSTING_V2,
      #     {
      #       body: "저장한 관심일자리에 연락해보세요.",
      #       title: "저장한 관심일자리 추천",
      #       "link": "carepartner://app/jobs/#{job_posting.public_id}?&utm_source=message&utm_medium=app_push&utm_campaign=call_saved_job_posting2"
      #     },
      #     user.public_id,
      #   )
      #   @app_push_list.push(app_push)
      # else
        params = {
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
        @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, "AI", user.phone_number, params, user.public_id))
      # end
    end
  end
end