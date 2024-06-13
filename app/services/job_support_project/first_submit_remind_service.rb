class JobSupportProject::FirstSubmitRemindService

  def initialize
    @job_support_project_participants = JobSupportProjectParticipant
                     .where('created_at >= ? AND created_at < ?', 2.days.ago.beginning_of_day, 2.days.ago.end_of_day)
                     .where(is_done: false, method: ['sms', 'fax'])
                     .includes(job_posting: { business: :business_registrations })
  end

  def call
    @job_support_project_participants.each do |job_support_project_participant|
      business_registrations = job_support_project_participant.job_posting.business.business_registrations
      if business_registrations.empty?
        # 안녕하세요 케어파트너입니다. 채용 지원금 서류 제출 기한이 오늘까지 입니다. 확인 후 제출해주세요.
        #
        # [제출 서류]
        #
        # 고유번호증 또는 사업자등록증 사업 참여 첫 1회만 제출
        #
        # **#{채용한 요보사선생님 이름}**님 근로계약서 (주소, 주민등록번호 전체 포함)
        #
        # [서류 제출 방법]
        #
        # 아래 방법 중 하나로 제출 해주세요
        #
        # 1588-5877로 문자 제출
        #
        # Fax : 07080157158
        #
        # 제출 기한: **#{오늘 날짜}**까지

        Notification::Lms(job_support_project_participant.job_posting.manager_phone_number, "").send
      else
        # 안녕하세요 케어파트너입니다. 채용 지원금 서류 제출 기한이 오늘까지 입니다. 확인 후 제출해주세요.
        #
        # [제출 서류]
        #
        # **#{채용한 요보사선생님 이름}**님 근로계약서 (주소, 주민등록번호 전체 포함)
        #
        # [서류 제출 방법]
        #
        # 아래 방법 중 하나로 제출 해주세요
        #
        # 1588-5877로 문자 제출
        #
        # Fax : 07080157158
        #
        # 제출 기한: **#{오늘 날짜}**까지
        Notification::Lms(job_support_project_participant.job_posting.manager_phone_number, "").send
      end

    end

  end

end