class JobSupportProject::SubmitRemindService
  include NotificationRequestHelper
  def initialize(standard_day_ago, title, due_day)
    # DB가 UTC 시간을 사용하고 있으므로 한국 시간(KST)을 기준으로 변경
    @kst_now = Time.now.in_time_zone('Asia/Seoul')
    start_time = (@kst_now - standard_day_ago.days).beginning_of_day
    end_time = (@kst_now - (standard_day_ago - 1).days).beginning_of_day

    @title = title
    @due_day = due_day

    current_year_start = Time.now.beginning_of_year
    current_year_end = Time.now.end_of_year

    @job_posting_results = JobPostingResult
                             .where('job_posting_results.created_at >= ? AND job_posting_results.created_at < ?', start_time.utc, end_time.utc)
                             .where(result_type: 'success')
                             .left_joins(:user)
                             .where('job_posting_results.user_id IS NULL OR users.birth_year <= ?', Time.now.year - 60)
                             .left_joins(job_posting: :job_support_project_participants)
                             .where('job_support_project_participants.id IS NULL OR job_support_project_participants.is_done = ?', false)
                             .joins("LEFT JOIN job_support_project_participants AS jsp ON job_posting_results.user_id = jsp.user_id AND jsp.is_done = TRUE AND jsp.created_at BETWEEN '#{current_year_start.utc}' AND '#{current_year_end.utc}'")
                             .where('jsp.id IS NULL')
  end

  def call
    @job_posting_results.each do |job_posting_result|
      business_registration = job_posting_result.job_posting.business.business_registration
      user_name = job_posting_result.user.name
      due_date = (@kst_now + @due_day.days).in_time_zone('Asia/Seoul').strftime('%m.%d')
      sms_body = "다음 문서들을 해당 번호로 보내주세요. 1. #{user_name}님 근로계약서 (주소, 주민등록번호 전체 포함)"
      message = "[채용 지원금 서류 제출 알림]\n\n안녕하세요 #{job_posting_result.job_posting.business.name} 담당자님 케어파트너입니다.\n#{@title}\n\n[제출 서류]"
      if business_registration.nil?
        message += "\n■ 센터의 고유번호증 또는 사업자등록증 (사업 참여 첫 1회만 제출)"
        sms_body += "2. 고유번호증 또는 사업자등록증"
      end
      message += "\n■ #{user_name}님 근로계약서 (주소, 주민등록번호 전체 포함)"
      message += "\n\n[서류 제출 방법]\n아래 방법 중 하나로 제출 해주세요 (세 가지 중 택 1)\n■ 바로 제출하기 > 하단 \"바로 제출하기\" 버튼을 눌러서 서류를 제출헤주세요.\n■ 문자로 제출하기 > 하단 \"문자로 제출하기\" 버튼을 눌러서 서류를 제출해주세요.\n■ Fax > 07080157158로 서류를 제출해주세요.\n\n제출 기한: #{due_date}까지"

      body = {
        message_type: "AI",
        receiver_num: job_posting_result.job_posting.manager_phone_number,
        profile_key: ENV['KAKAO_BIZMSG_PROFILE'],
        template_code: 'job_support_document_reminder',
        sender_num: '15885877',
        msgid: "WEB#{Time.now.strftime("%y%m%d%H%M%S")}_#{SecureRandom.uuid.gsub('-', '')[0, 7]}",
        message: message,
        reserved_time: '00000000000000',
        button1: {
          name: '바로 제출하기',
          type: 'WL',
          url_mobile: "https://business.carepartner.kr/jspp",
          url_pc: "https://business.carepartner.kr/jspp"
        },
        button2: {
          name: '문자로 제출하기',
          type: 'AL',
          scheme_android: "sms://15885877?body=#{sms_body}",
          scheme_ios: "sms://15885877&body=#{sms_body}",
        }
      }

      p body
      res = request_post_pay(body)
      p res
    end
  end
end
