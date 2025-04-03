
module MessageTemplateName
  NEW_JOB_POSTING_VISIT = "new_job_visit(no_hotdeal)".freeze
  NEW_JOB_POSTING_FACILITY = "new_job_facility(no_hotdeal)".freeze
  PERSONALIZED = "personalized_job_message_edit3".freeze # done
  EXTRA_BENEFIT = "extra_benefits_job_message_4".freeze
  PROPOSAL_ACCEPTED = "proposal_accepted3".freeze
  PROPOSAL_REJECTED = "proposal_refused".freeze
  PROPOSAL_RESPONSE_EDIT = 'proposal_response(edit)'.freeze
  USER_SURVEY_FOLLOW_UP_EDIT = 'user_survey_follow_up(edit)'.freeze
  USER_CALL_REMINDER = "proposal_call_remind_user1".freeze # 기관이 요양보호사에게 전화했을 때 안받은 경우
  BUSINESS_CALL_REMINDER = "posting_call_reminder_biz1".freeze # 요보사가 기관에게 전화했을 때 안받은 경우
  MISSED_CAREGIVER_TO_BUSINESS_CALL = "missed_call_biz".freeze # 요보사 => 기관 부재중 알림
  CALL_REQUEST_ALARM = "call_request_alarm".freeze # 요양보호사가 기관에 지원했을 때, 기관에게 지원 안내를 하는 알림톡입니다.
  BUSINESS_CALL_APPLY_USER_REMINDER = "call_request_remind".freeze # 요양보호사가 기관 일자리 상담 전화를 안받은 경우
  JOB_ALARM_ACTIVELY = 'job_alarm(actively)'.freeze # 적극구직 요양보호사에게 매일 전달되는 신문
  JOB_ALARM_COMMON = 'job_alarm(common)'.freeze # 구직중 요양보호사에게 월,목 전달되는 신문
  JOB_ALARM_OFF = 'job_alarm(off)'.freeze # 구직의사 없음 요양보호사에게 매달 첫번째 월요일 오후 12시에 전달되는 신문
  JOB_ALARM_WORKING = 'job_alarm(working)'.freeze # 일하는 중인 요양보호사에게 매달 첫째주,셋째주 월요일 오후 12시에 전달되는 신문
  GAMIFICATION_MISSION_COMPLETE = 'plant_mission_complete'.freeze # 식물키우기 미션달성 메세지 발송
  CAREER_CERTIFICATION = 'career_certification' # 경력 인증 알림톡
  CAREER_CERTIFICATION_V2 = 'career_certification_v2' # 취업인증 개선 알림톡
  CAREER_CERTIFICATION_V3 = 'career_certification_v3' # 취업확인 알림톡

  CONNECT_RESULT_USER_SURVEY_A = 'connect_result_user_survey A' # 취업 인증 (상품권)
  CONNECT_RESULT_USER_SURVEY_B = 'connect_result_user_survey B' # 취업 인증 (급여확인)
  CANDIDATE_RECOMMENDATION = 'candidate_recommendation'.freeze
  SIGNUP_COMPLETE_GUIDE = 'sign_up_complete_guide'.freeze # 가입(= 추가정보입력) 완료 알림톡
  SIGNUP_COMPLETE_GUIDE3 = 'sign_up_complete_guide3'.freeze # 가입(= 추가정보입력) 완료 알림톡
  CERTIFICATION_UPDATE = 'certification-update'.freeze # 시험 예정일 3일/7일이 지난 자격증 미취득 유저에게 소지 전환 유도
  POST_COMMENT = 'post-comment'.freeze # 게시글 답변 알림톡
  CALL_INTERVIEW_PROPOSAL = 'call_interview_proposal'.freeze
  CALL_INTERVIEW_PROPOSAL_V2 = 'call_interview_proposal_v2'.freeze
  CALL_INTERVIEW_ACCEPTED = 'call_interview_proposal_accept'.freeze
  CALL_SAVED_JOB_CAREGIVER = 'call_saved_care(close_avail)'.freeze # 공고에 관심표시한 요양보호사 기관에게 알림톡
  CALL_SAVED_JOB_POSTING_V2 = 'call_saved_job_posting_v2'.freeze
  # TFT 구직상태 업데이트 시 추가된 템플릿
  ASK_ACTIVE = 'Off_Job_Proposal_Notification'.freeze
  NEW_JOB_VISIT_V2 = 'new_job_visit(23-09-2w)'.freeze
  NEW_JOB_FACILITY_V2 = 'new_job_facility(23-09-2w)'.freeze
  NEWSPAPER_V2 = 'newspaper_job_alarm'.freeze
  NEWSPAPER_V3 = 'newspaper_job_alarm_v2'.freeze
  COUPANG_PARTNERS_BENEFIT = 'coupang_partners_benefit'.freeze
  QUIZ_5_BENEFIT = 'quiz_5_benefit'.freeze

  # 동네광고 관련
  TARGET_USER_JOB_POSTING = 'target_user_job_posting'.freeze # 신규일자리 알림을 타겟 사용자에게 전송
  TARGET_JOB_POSTING_PERFORMANCE = 'target_job_posting_performance'.freeze # 동네광고 성과
  TARGET_JOB_POSTING_AD_APPLY = 'target_job_posting_ad_apply_v2'.freeze # 동네광고 타겟 사용자의 지원시 기관 알림

  # B2G 관련
  JOB_SUPPORT_REQUEST_AGREEMENT = 'job_support_request_agreement'.freeze # 일자리 지원사업 요보사 동의 요청

  ACCUMULATED_DRAFT = 'accumulated_draft'.freeze
  ACCUMULATED_PREPARATIVE = 'accumulated_preparative'.freeze
  # 간편 지원
  JOB_APPLICATION = 'job_application (close_avail)'.freeze

  # 공고 자동종료 1일전 알림
  CLOSE_JOB_POSTING_REMIND_1DAY_AGO = 'close_jobposting_remind_1dago'

  # 룰렛 수령 알림
  ROULETTE = 'roulette'.freeze

  # 전화면접 제안
  PROPOSAL = "proposal".freeze
  # 입주요양 전화면접 제안
  PROPOSAL_RESIDENT = "proposal_resident".freeze

  # 문자문의
  CONTACT_MESSAGE = 'contact_message (close_avail)'.freeze

  # 제안 수락 알림 메시지
  PROPOSAL_ACCEPT = 'proposal_accept (close_avail)'.freeze

  # 요보사 취업인증 완료 후 기관에 확인 알림톡
  CONFIRM_CAREER_CERTIFICATION = 'confirm_career_certification'.freeze

  # 공고 등록 완료
  BUSINESS_JOB_POSTING_COMPLETE = 'business_job_posting_complete'.freeze

  # 스마트 메모 홍보
  SMART_MEMO = 'smart_memo'.freeze

  # 돌봄플러스 신청 알림
  NONE_LTC_REQUEST = 'nonltc_01'.freeze

  USER_PUSH_ALERT = 'user_push_alert'.freeze

  TARGET_USER_JOB_POSTING_V3 = 'target_user_job_posting_V3'.freeze
  TARGET_USER_JOB_POSTING_V2 = 'target_user_job_posting_V2'.freeze
  TARGET_USER_RESIDENT_POSTING = 'target_user_resident_posting'.freeze
end