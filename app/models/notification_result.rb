class NotificationResult < ApplicationRecord
  include AlimtalkMessage
  PROPOSAL = "proposal".freeze
  PROPOSAL_ACCEPT = "proposal_accept (close_avail)".freeze
  PERSONALIZED = "personalized_notification".freeze
  EXTRA_BENEFIT = "extra_benefit_notification".freeze
  PROPOSAL_ACCEPTED = "proposal_accepted".freeze
  PROPOSAL_REJECTED = "proposal_refused".freeze
  SATISFACTION_SURVEY = "business_call_survey".freeze
  USER_SATISFACTION_SURVEY = "user_satisfaction_survey".freeze
  USER_CALL_FAILURE_ALERT = "user_calls_failure_alert".freeze
  BUSINESS_CALL_FAILURE_ALERT = "business_calls_failure_alert".freeze
  BUSINESS_CALL_APPLY_USER_FAILURE_ALERT = "business_call_apply_user_failure_alert".freeze
  CALL_REQUEST_ALARM = "call_request_alarm".freeze
  NEWS_PAPER = 'news_paper'.freeze
  GAMIFICATION_MISSION_COMPLETE = 'plant_mission_complete'.freeze
  CAREER_CERTIFICATION = 'career_certification'.freeze
  CAREER_CERTIFICATION_V2 = 'career_certification_v2'.freeze
  CAREER_CERTIFICATION_V3 = 'career_certification_v3'.freeze
  JOB_CERTIFICATION = 'job_certification'.freeze
  NOTIFY_MATCHED_USER = 'notify_matched_user'.freeze
  SIGNUP_COMPLETE_GUIDE = 'sign_up_complete_guide'.freeze
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
  ACCUMULATED_DRAFT = 'accumulated_draft'.freeze
  ACCUMULATED_PREPARATIVE = 'accumulated_preparative'.freeze
  ROULETTE = 'roulette'.freeze
  NEWSPAPER_JOB_ALARM = 'newspaper_job_alarm'.freeze
  TARGET_USER_JOB_POSTING_V2 = MessageTemplateName::TARGET_USER_JOB_POSTING_V2
  TARGET_JOB_POSTING_AD_APPLY = MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY

  # 과금 대상 무료공고 종료 관련
  NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO = 'free_job_posting_close_1dayago'.freeze
  NOTIFY_FREE_JOB_POSTING_CLOSE = 'free_job_posting_close'.freeze

  BUSINESS_JOB_POSTING_COMPLETE = 'business_job_posting_complete'.freeze

  validates :used_medium, inclusion: { in: %w(kakao_arlimtalk app_push) }
  validates :send_type, presence: true
  validates :template_id, presence: true
  validates :success_count, numericality: { grater_than_or_equal_to: 0 }
  validates :fail_count, numericality: { grater_than_or_equal_to: 0 }

  enum send_type: {
    CALL_INTERVIEW_ACCEPTED => CALL_INTERVIEW_ACCEPTED,
    PROPOSAL => 'proposal',
    PROPOSAL_ACCEPT => 'proposal_accept',
    PERSONALIZED => "personalized_notification",
    EXTRA_BENEFIT => "extra_benefit_notification",
    PROPOSAL_ACCEPTED => "proposal_accepted",
    PROPOSAL_REJECTED => "proposal_refused",
    SATISFACTION_SURVEY => SATISFACTION_SURVEY,
    TARGET_USER_JOB_POSTING_V2 => TARGET_USER_JOB_POSTING_V2,
    TARGET_JOB_POSTING_AD_APPLY => TARGET_JOB_POSTING_AD_APPLY,
    USER_SATISFACTION_SURVEY => USER_SATISFACTION_SURVEY,
    USER_CALL_FAILURE_ALERT => USER_CALL_FAILURE_ALERT,
    BUSINESS_CALL_FAILURE_ALERT => BUSINESS_CALL_FAILURE_ALERT,
    CALL_REQUEST_ALARM => CALL_REQUEST_ALARM,
    BUSINESS_CALL_APPLY_USER_FAILURE_ALERT => BUSINESS_CALL_APPLY_USER_FAILURE_ALERT,
    NEWS_PAPER => NEWS_PAPER,
    GAMIFICATION_MISSION_COMPLETE => GAMIFICATION_MISSION_COMPLETE,
    CAREER_CERTIFICATION => CAREER_CERTIFICATION,
    CAREER_CERTIFICATION_V2 => CAREER_CERTIFICATION_V2,
    CAREER_CERTIFICATION_V3 => CAREER_CERTIFICATION_V3,
    JOB_CERTIFICATION => JOB_CERTIFICATION,
    NOTIFY_MATCHED_USER => NOTIFY_MATCHED_USER,
    SIGNUP_COMPLETE_GUIDE => SIGNUP_COMPLETE_GUIDE,
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
    ACCUMULATED_DRAFT => ACCUMULATED_DRAFT,
    ACCUMULATED_PREPARATIVE => ACCUMULATED_PREPARATIVE,
    NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO => NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO,
    NOTIFY_FREE_JOB_POSTING_CLOSE => NOTIFY_FREE_JOB_POSTING_CLOSE,
    ROULETTE => ROULETTE,
    NEWSPAPER_JOB_ALARM => NEWSPAPER_JOB_ALARM,
    PROPOSAL_ACCEPT => PROPOSAL_ACCEPT,
    BUSINESS_JOB_POSTING_COMPLETE => BUSINESS_JOB_POSTING_COMPLETE,
    MessageTemplateName::SMART_MEMO => MessageTemplateName::SMART_MEMO,
    MessageTemplateName::TARGET_USER_JOB_POSTING => MessageTemplateName::TARGET_USER_JOB_POSTING,
    MessageTemplateName::TARGET_JOB_POSTING_PERFORMANCE => MessageTemplateName::TARGET_JOB_POSTING_PERFORMANCE,
    MessageTemplateName::TARGET_JOB_POSTING_AD => MessageTemplateName::TARGET_JOB_POSTING_AD,
    MessageTemplates[MessageNames::TARGET_JOB_POSTING_AD_2] => MessageNames::TARGET_JOB_POSTING_AD_2,
    MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY => MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY,
    MessageTemplateName::NONE_LTC_REQUEST => MessageTemplateName::NONE_LTC_REQUEST,
    MessageTemplateName::JOB_SUPPORT_REQUEST_AGREEMENT => MessageTemplateName::JOB_SUPPORT_REQUEST_AGREEMENT,
    MessageTemplateName::TARGET_USER_RESIDENT_POSTING => MessageTemplateName::TARGET_USER_RESIDENT_POSTING,
    MessageTemplateName::PROPOSAL_RESIDENT => MessageTemplateName::PROPOSAL_RESIDENT,
    MessageTemplates[MessageNames::TARGET_USER_JOB_POSTING] => MessageNames::TARGET_USER_JOB_POSTING,
    MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_DRAFT_CRM] => MessageNames::ONE_DAY_CAREPARTNER_DRAFT_CRM,
    MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_ADDRESS_LEAK_CRM] => MessageNames::ONE_DAY_CAREPARTNER_ADDRESS_LEAK_CRM,
    MessageTemplates[MessageNames::TWO_DAY_CAREPARTNER_DRAFT_CRM] => MessageNames::TWO_DAY_CAREPARTNER_DRAFT_CRM,
    MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM] => MessageNames::ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM,
    MessageTemplates[MessageNames::CBT_DRAFT_CRM] => MessageNames::CBT_DRAFT_CRM
  }
end
