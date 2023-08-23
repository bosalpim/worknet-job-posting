class KakaoNotificationResult < ApplicationRecord
  PROPOSAL = "proposal".freeze
  NEW_JOB_POSTING = "new_job_posting".freeze
  PERSONALIZED = "personalized_notification".freeze
  EXTRA_BENEFIT = "extra_benefit_notification".freeze
  PROPOSAL_ACCEPTED = "proposal_accepted".freeze
  PROPOSAL_REJECTED = "proposal_refused".freeze
  SATISFACTION_SURVEY = "satisfaction_survey".freeze
  USER_SATISFACTION_SURVEY = "user_satisfaction_survey".freeze
  USER_CALL_FAILURE_ALERT = "user_calls_failure_alert".freeze
  BUSINESS_CALL_FAILURE_ALERT = "business_calls_failure_alert".freeze
  BUSINESS_CALL_APPLY_USER_FAILURE_ALERT = "business_call_apply_user_failure_alert".freeze
  CALL_REQUEST_ALARM = "call_request_alarm".freeze
  NEWS_PAPER = 'news_paper'.freeze
  GAMIFICATION_MISSION_COMPLETE = 'plant_mission_complete'.freeze
  CONTRACT_AGENCY_ALARM = 'Contract_agency_alarm'.freeze # 기관 근로 계약서 작성 대행 알림톡
  CAREER_CERTIFICATION = 'career_certification'.freeze
  NOTIFY_MATCHED_USER = 'notify_matched_user'.freeze
  SIGNUP_COMPLETE_GUIDE = 'sign_up_complete_guide'.freeze
  HIGH_SALARY_JOB = 'high-salary-job-2'.freeze
  ENTER_LOCATION = 'enter-location'.freeze


  validates :send_type, presence: true
  validates :template_id, presence: true
  validates :success_count, numericality: { grater_than_or_equal_to: 0 }
  validates :fail_count, numericality: { grater_than_or_equal_to: 0 }

  enum send_type: {
    PROPOSAL => 'proposal',
    NEW_JOB_POSTING => "new_job_posting",
    PERSONALIZED => "personalized_notification",
    EXTRA_BENEFIT => "extra_benefit_notification",
    PROPOSAL_ACCEPTED => "proposal_accepted",
    PROPOSAL_REJECTED => "proposal_refused",
    SATISFACTION_SURVEY => SATISFACTION_SURVEY,
    USER_SATISFACTION_SURVEY => USER_SATISFACTION_SURVEY,
    USER_CALL_FAILURE_ALERT => USER_CALL_FAILURE_ALERT,
    BUSINESS_CALL_FAILURE_ALERT => BUSINESS_CALL_FAILURE_ALERT,
    CALL_REQUEST_ALARM => CALL_REQUEST_ALARM,
    BUSINESS_CALL_APPLY_USER_FAILURE_ALERT => BUSINESS_CALL_APPLY_USER_FAILURE_ALERT,
    NEWS_PAPER => NEWS_PAPER,
    GAMIFICATION_MISSION_COMPLETE => GAMIFICATION_MISSION_COMPLETE,
    CONTRACT_AGENCY_ALARM => CONTRACT_AGENCY_ALARM,
    CAREER_CERTIFICATION => CAREER_CERTIFICATION,
    NOTIFY_MATCHED_USER => NOTIFY_MATCHED_USER,
    SIGNUP_COMPLETE_GUIDE => SIGNUP_COMPLETE_GUIDE,
    HIGH_SALARY_JOB => HIGH_SALARY_JOB,
    ENTER_LOCATION => ENTER_LOCATION
  }
end
