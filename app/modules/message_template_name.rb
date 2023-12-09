module MessageTemplateName

  NEW_JOB_POSTING_VISIT = "new_job_visit(no_hotdeal)".freeze
  NEW_JOB_POSTING_FACILITY = "new_job_facility(no_hotdeal)".freeze
  PERSONALIZED = "personalized_job_message_edit3".freeze # done
  EXTRA_BENEFIT = "extra_benefits_job_message_4".freeze
  PROPOSAL_ACCEPTED = "proposal_accepted3".freeze
  PROPOSAL_REJECTED = "proposal_refused".freeze
  PROPOSAL_RESPONSE_EDIT = 'proposal_response(edit)'.freeze
  SATISFACTION_SURVEY = "business_satisfaction_survey".freeze # 기관 채용만족도 조사 알림톡
  USER_SATISFACTION_SURVEY = "user_satisfaction_survey(edit)".freeze # 요양보호사 채용만족도 조사 알림톡
  USER_SATISFACTION_SURVEY_2 = "user_satisfaction_survey2".freeze
  USER_SURVEY_FOLLOW_UP_EDIT = 'user_survey_follow_up(edit)'.freeze
  USER_CALL_REMINDER = "proposal_call_remind_user1".freeze # 기관이 요양보호사에게 전화했을 때 안받은 경우
  BUSINESS_CALL_REMINDER = "posting_call_reminder_biz1".freeze # 요보사가 기관에게 전화했을 때 안받은 경우
  CALL_REQUEST_ALARM = "call_request_alarm".freeze # 요양보호사가 기관에 지원했을 때, 기관에게 지원 안내를 하는 알림톡입니다.
  BUSINESS_CALL_APPLY_USER_REMINDER = "call_request_remind".freeze # 요양보호사가 기관 일자리 상담 전화를 안받은 경우
  JOB_ALARM_ACTIVELY = 'job_alarm(actively)'.freeze # 적극구직 요양보호사에게 매일 전달되는 신문
  JOB_ALARM_COMMON = 'job_alarm(common)'.freeze # 구직중 요양보호사에게 월,목 전달되는 신문
  JOB_ALARM_OFF = 'job_alarm(off)'.freeze # 구직의사 없음 요양보호사에게 매달 첫번째 월요일 오후 12시에 전달되는 신문
  JOB_ALARM_WORKING = 'job_alarm(working)'.freeze # 일하는 중인 요양보호사에게 매달 첫째주,셋째주 월요일 오후 12시에 전달되는 신문
  GAMIFICATION_MISSION_COMPLETE = 'plant_mission_complete'.freeze # 식물키우기 미션달성 메세지 발송
  CAREER_CERTIFICATION = 'career_certification' # 경력 인증 알림톡
  CAREER_CERTIFICATION_V2 = 'career_certification_v2' # 취업인증 개선 알림톡
  CONNECT_RESULT_USER_SURVEY_A = 'connect_result_user_survey A' # 취업 인증 (상품권)
  CONNECT_RESULT_USER_SURVEY_B = 'connect_result_user_survey B' # 취업 인증 (급여확인)
  CLOSE_JOB_POSTING_NOTIFICATION = 'close_job_posting_notification'.freeze # 공고 종료 알림톡
  CANDIDATE_RECOMMENDATION = 'candidate_recommendation'.freeze
  SIGNUP_COMPLETE_GUIDE = 'sign_up_complete_guide'.freeze # 가입(= 추가정보입력) 완료 알림톡
  SIGNUP_COMPLETE_GUIDE3 = 'sign_up_complete_guide3'.freeze # 가입(= 추가정보입력) 완료 알림톡
  HIGH_SALARY_JOB = 'high-salary-job-2'.freeze # 가입 1일차 draft, 자격증 소지자 (주소입력 제외하고)
  ENTER_LOCATION = 'enter-location'.freeze # 가입 1일차 draft, 자격증 소지자 중 주소입력 단계 이탈자
  WELL_FITTED_JOB = 'well-fitted-job'.freeze # 가입 2일차 draft, 자격증 소지자
  CERTIFICATION_UPDATE = 'certification-update'.freeze # 시험 예정일 3일/7일이 지난 자격증 미취득 유저에게 소지 전환 유도
  POST_COMMENT = 'post-comment'.freeze # 게시글 답변 알림톡
  CALL_INTERVIEW_PROPOSAL = 'call_interview_proposal'.freeze
  CALL_INTERVIEW_PROPOSAL_V2 = 'call_interview_proposal_v2'.freeze
  CALL_INTERVIEW_ACCEPTED = 'call_interview_proposal_accept'.freeze
  CALL_SAVED_JOB_CAREGIVER = 'call_saved_job_caregiver'.freeze # 공고에 관심표시한 요양보호사 기관에게 알림톡
  CALL_SAVED_JOB_POSTING_V2 = 'call_saved_job_posting_v2'.freeze
  # TFT 구직상태 업데이트 시 추가된 템플릿
  ASK_ACTIVE = 'Off_Job_Proposal_Notification'.freeze
  NEW_JOB_VISIT_V2 = 'new_job_visit(23-09-2w)'.freeze
  NEW_JOB_FACILITY_V2 = 'new_job_facility(23-09-2w)'.freeze
  NEWSPAPER_V2 = 'newspaper_job_alarm'.freeze
  # 신규일자리알림
  NEW_JOB_POSTING = 'new_job_posting'.freeze
  CBT_DRAFT = 'CBT_draft2'.freeze # cbt 가입 draft 1일, 2일, 3일 뒤 대상
  CAREPARTNER_PRESENT = 'carepartner_present'.freeze
  ACCUMULATED_DRAFT = 'accumulated_draft'.freeze
  ACCUMULATED_PREPARATIVE = 'accumulated_preparative'.freeze
  # 간편 지원
  JOB_APPLICATION = 'job_application'.freeze

  # 과금 대상 무료공고 종료 관련
  NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO = 'free_job_posting_close_1dayago'.freeze
  NOTIFY_FREE_JOB_POSTING_CLOSE = 'free_job_posting_close'.freeze

  # 룰렛 수령 알림
  ROULETTE = 'roulette'.freeze

  # 전화면접 제안
  PROPOSAL = "proposal".freeze

  #문자문의
  CONTACT_MESSAGE = 'contact_message'.freeze

  # 구인광고 메세지
  JOB_ADS_MESSAGE_FIRST = 'job_ads_message_first'.freeze
end