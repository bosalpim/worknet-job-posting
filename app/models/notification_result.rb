class NotificationResult < ApplicationRecord
  PROPOSAL = "proposal".freeze
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
  CAREER_CERTIFICATION = 'career_certification'.freeze
  NOTIFY_MATCHED_USER = 'notify_matched_user'.freeze
  SIGNUP_COMPLETE_GUIDE = 'sign_up_complete_guide'.freeze
  HIGH_SALARY_JOB = 'high-salary-job-2'.freeze
  ENTER_LOCATION = 'enter-location'.freeze
  WELL_FITTED_JOB = 'well-fitted-job'.freeze
  CERTIFICATION_UPDATE = 'certification-update'.freeze
  POST_COMMENT = 'post-comment'.freeze # 게시글 답변 알림톡
  CALL_INTERVIEW_PROPOSAL = 'call_interview_proposal'.freeze
  CALL_INTERVIEW_ACCEPTED = 'call_interview_accepted'.freeze
  CALL_SAVED_JOB_CAREGIVER = 'call_saved_job_caregiver'.freeze # 공고에 관심표시한 요양보호사 기관에게 알림톡
  CALL_SAVED_JOB_POSTING_V2 = 'call_saved_job_posting_v2'.freeze
  ASK_ACTIVE = 'ask_active'.freeze
  NEW_JOB_VISIT_V2 = 'new_job_visit_v2'.freeze
  NEW_JOB_FACILITY_V2 = 'new_job_facility(23-09-2w)'.freeze
  NEWSPAPER_V2 = 'newspaper_v2'.freeze
  CBT_DRAFT = 'CBT_draft2'.freeze # cbt 가입 draft 1일, 2일, 3일 뒤 대상
  CAREPARTNER_PRESENT = 'carepartner_present'.freeze
  ACCUMULATED_DRAFT = 'accumulated_draft'.freeze
  ACCUMULATED_PREPARATIVE = 'accumulated_preparative'.freeze

  # 신규일자리알림
  NEW_JOB_POSTING = 'new_job_posting'.freeze

  validates :used_medium, inclusion: { in: %w(kakao_arlimtalk app_push) }
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
    CAREER_CERTIFICATION => CAREER_CERTIFICATION,
    NOTIFY_MATCHED_USER => NOTIFY_MATCHED_USER,
    SIGNUP_COMPLETE_GUIDE => SIGNUP_COMPLETE_GUIDE,
    HIGH_SALARY_JOB => HIGH_SALARY_JOB,
    ENTER_LOCATION => ENTER_LOCATION,
    WELL_FITTED_JOB => WELL_FITTED_JOB,
    CERTIFICATION_UPDATE => CERTIFICATION_UPDATE,
    POST_COMMENT => POST_COMMENT,
    CALL_INTERVIEW_PROPOSAL => CALL_INTERVIEW_PROPOSAL,
    CALL_INTERVIEW_ACCEPTED => CALL_INTERVIEW_ACCEPTED,
    CALL_SAVED_JOB_CAREGIVER => CALL_SAVED_JOB_CAREGIVER,
    CALL_SAVED_JOB_POSTING_V2 => CALL_SAVED_JOB_POSTING_V2,
    NEWSPAPER_V2 => NEWSPAPER_V2,
    NEW_JOB_VISIT_V2 => NEW_JOB_VISIT_V2,
    NEW_JOB_FACILITY_V2 => NEW_JOB_FACILITY_V2,
    ASK_ACTIVE => ASK_ACTIVE,
    NEW_JOB_POSTING => NEW_JOB_POSTING,
    CBT_DRAFT => CBT_DRAFT,
    CAREPARTNER_PRESENT => CAREPARTNER_PRESENT,
    ACCUMULATED_DRAFT => ACCUMULATED_DRAFT,
    ACCUMULATED_PREPARATIVE => ACCUMULATED_PREPARATIVE
  }
end