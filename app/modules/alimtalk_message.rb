# frozen_string_literal: true
# 알림톡 메세지 이름과 템플릿 코드 관리
module AlimtalkMessage
  # 알림톡 메세지 이름을 상수로 정의
  module MessageNames
    # 신규 공고 알림톡
    TARGET_USER_JOB_POSTING = "target_user_job_posting"
    TARGET_JOB_POSTING_AD_2 = "target_job_posting_ad_2"
    ONE_DAY_CAREPARTNER_DRAFT_CRM = 'one_day_carepartner_draft_crm'
    ONE_DAY_CAREPARTNER_ADDRESS_LEAK_CRM = 'one_day_carepartner_address_leak_crm'
    ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM = 'one_day_carepartner_certification_leak_crm'
    TWO_DAY_CAREPARTNER_DRAFT_CRM = 'two_day_carepartner_draft_crm'
    CBT_DRAFT_CRM = 'cbt_draft_crm'
    TARGET_JOB_BUSINESS_FREE_TRIALS = 'target_user_business_free_trials'
  end

  module MessageTemplates
    TEMPLATES = {
      MessageNames::TARGET_USER_JOB_POSTING => "target_user_job_posting_V5",
      MessageNames::TARGET_JOB_POSTING_AD_2 => "target_job_posting_ad_2",
      MessageNames::ONE_DAY_CAREPARTNER_DRAFT_CRM => "high-salary-job",
      MessageNames::ONE_DAY_CAREPARTNER_ADDRESS_LEAK_CRM => 'enter-location-1',
      MessageNames::ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM => 'carepartner-present',
      MessageNames::TWO_DAY_CAREPARTNER_DRAFT_CRM => 'well-fitted-job-1',
      MessageNames::CBT_DRAFT_CRM => 'CBT-draft',
      MessageNames::TARGET_JOB_BUSINESS_FREE_TRIALS => 'target_user_business_tutorial'
    }.freeze

    def self.[](message_name)
      TEMPLATES[message_name]
    end
  end
end
