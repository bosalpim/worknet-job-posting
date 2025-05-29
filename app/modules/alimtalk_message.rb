# frozen_string_literal: true
# 알림톡 메세지 이름과 템플릿 코드 관리
module AlimtalkMessage
  # 알림톡 메세지 이름을 상수로 정의
  module MessageNames
    # 신규 공고 알림톡
    TARGET_USER_JOB_POSTING = "target_user_job_posting"
    PLUSTALK = "plustalk"
    ONE_DAY_CAREPARTNER_DRAFT_CRM = 'one_day_carepartner_draft_crm'
    ONE_DAY_CAREPARTNER_ADDRESS_LEAK_CRM = 'one_day_carepartner_address_leak_crm'
    ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM = 'one_day_carepartner_certification_leak_crm'
    TWO_DAY_CAREPARTNER_DRAFT_CRM = 'two_day_carepartner_draft_crm'
    CBT_DRAFT_CRM = 'cbt_draft_crm'
    TARGET_JOB_BUSINESS_FREE_TRIALS = 'target_user_business_free_trials'
    CLOSE_JOB_POSTING_NOTIFICATION='close_job_posting_notification'
    TARGET_USER_RESIDENT_JOB_POSTING = "target_user_resident_posting"
    ACADEMY_EXAM_GUIDE = "exam_guide"
    ACADEMY_EXAM_TRANSITION = "exam_transition"
  end

  module MessageTemplates
    TEMPLATES = {
      MessageNames::TARGET_USER_JOB_POSTING => "target_user_job_posting_V7",
      MessageNames::ONE_DAY_CAREPARTNER_DRAFT_CRM => "high-salary-job",
      MessageNames::ONE_DAY_CAREPARTNER_ADDRESS_LEAK_CRM => 'enter-location-1',
      MessageNames::ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM => 'carepartner-present',
      MessageNames::TWO_DAY_CAREPARTNER_DRAFT_CRM => 'well-fitted-job-1',
      MessageNames::CBT_DRAFT_CRM => 'CBT-draft',
      MessageNames::TARGET_JOB_BUSINESS_FREE_TRIALS => 'target_user_business_tutorial',
      MessageNames::CLOSE_JOB_POSTING_NOTIFICATION => 'noti_job_posting_auto_close',
      MessageNames::TARGET_USER_RESIDENT_JOB_POSTING => 'target_user_resident_posting1',
      MessageNames::ACADEMY_EXAM_GUIDE => 'exam_guide',
      MessageNames::ACADEMY_EXAM_TRANSITION => 'exam_transition',
    }.freeze

    def self.[](message_name)
      TEMPLATES[message_name]
    end
  end
end
