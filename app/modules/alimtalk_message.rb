# frozen_string_literal: true
# 알림톡 메세지 이름과 템플릿 코드 관리
module AlimtalkMessage
  # 알림톡 메세지 이름을 상수로 정의
  module MessageNames
    # 신규 공고 알림톡
    TARGET_USER_JOB_POSTING = "target_user_job_posting"
    TARGET_JOB_POSTING_AD_2 = "target_job_posting_ad_2"
    ONE_DAY_CAREPARTNER_DRAFT_CRM = 'one_day_carepartner_draft_crm'
  end

  module MessageTemplates
    TEMPLATES = {
      MessageNames::TARGET_USER_JOB_POSTING => "target_user_job_posting_v4",
      MessageNames::TARGET_JOB_POSTING_AD_2 => "target_job_posting_ad_2",
      MessageNames::ONE_DAY_CAREPARTNER_DRAFT_CRM => "high-salary-job"
    }.freeze

    def self.[](message_name)
      TEMPLATES[message_name]
    end
  end
end
