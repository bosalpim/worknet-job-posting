class JobSupportProject::SubmitRemindService
  def initialize(standard_day_ago, title, due_day)
    # DB가 UTC 시간을 사용하고 있으므로 한국 시간(KST)을 기준으로 변경
    @kst_now = Time.now.in_time_zone('Asia/Seoul')
    start_time = (@kst_now - standard_day_ago.days).beginning_of_day
    end_time = (@kst_now - (standard_day_ago - 1).days).beginning_of_day

    @title = title
    @due_day = due_day

    @job_support_project_participants = JobSupportProjectParticipant
                                          .where('created_at >= ? AND created_at < ?', start_time.utc, end_time.utc)
                                          .where(is_done: false, method: ['sms', 'fax'])
                                          .includes(job_posting: { business: :business_registration })
  end

  def call
    Jets.logger.info "-------------- FirstSubmitRemind START --------------\n"
    @job_support_project_participants.each do |job_support_project_participant|
      Jets.logger.info "-------------- INFO START --------------\n"
      Jets.logger.info "#{job_support_project_participant.id} 대상 리마인드 발송\n"

      business_registration = job_support_project_participant.job_posting.business.business_registration
      user_name = job_support_project_participant.user.name
      due_date = (@kst_now + @due_day.days).in_time_zone('Asia/Seoul').strftime('%m.%d')

      if business_registration.nil?
        Jets.logger.info "사업자 등록증 없는 경우"
        message = "#{@title}

[제출 서류]
1. 고유번호증 또는 사업자등록증 사업 참여 첫 1회만 제출
2. #{user_name}님 근로계약서 (주소, 주민등록번호 전체 포함)

[서류 제출 방법]
아래 방법 중 하나로 제출 해주세요
■ 1588-5877로 문자 제출
■ Fax : 07080157158

제출 기한: #{due_date}까지"
        Notification::Lms.new(phone_number: job_support_project_participant.job_posting.manager_phone_number, message: message).send
      else
        Jets.logger.info "사업자 등록증 있는 경우\n"
        message = "#{@title}

[제출 서류]
■ #{user_name}님 근로계약서 (주소, 주민등록번호 전체 포함)

[서류 제출 방법]
아래 방법 중 하나로 제출 해주세요
■ 1588-5877로 문자 제출
■ Fax : 07080157158

제출 기한: #{due_date}까지"
        Notification::Lms.new(phone_number: job_support_project_participant.job_posting.manager_phone_number, message: message).send
      end
      Jets.logger.info "-------------- INFO END --------------\n"
    end
  end
end
