module KakaoTemplate
  PROPOSAL = "proposal_response".freeze
  NEW_JOB_POSTING_VISIT = "new_job_visit(no_hotdeal)".freeze
  NEW_JOB_POSTING_FACILITY = "new_job_facility(no_hotdeal)".freeze
  PERSONALIZED = "personalized_job_message_edit3".freeze # done
  EXTRA_BENEFIT = "extra_benefits_job_message_4".freeze
  PROPOSAL_ACCEPTED = "proposal_accepted3".freeze
  PROPOSAL_REJECTED = "proposal_refused".freeze
  SATISFACTION_SURVEY = "business_satisfaction_survey".freeze # 기관 채용만족도 조사 알림톡
  USER_SATISFACTION_SURVEY = "user_satisfaction_survey(edit)".freeze # 요양보호사 채용만족도 조사 알림톡
  USER_CALL_REMINDER = "proposal_call_remind_user1".freeze # 기관이 요양보호사에게 전화했을 때 안받은 경우
  BUSINESS_CALL_REMINDER = "posting_call_reminder_biz1".freeze # 요보사가 기관에게 전화했을 때 안받은 경우
  CALL_REQUEST_ALARM = "call_request_alarm".freeze # 요양보호사가 기관에 지원했을 때, 기관에게 지원 안내를 하는 알림톡입니다.
  BUSINESS_CALL_APPLY_USER_REMINDER = "call_request_remind".freeze # 요양보호사가 기관 일자리 상담 전화를 안받은 경우
  JOB_ALARM_ACTIVELY = 'job_alarm(actively)'.freeze # 적극구직 요양보호사에게 매일 전달되는 신문
  JOB_ALARM_COMMON = 'job_alarm(common)'.freeze # 구직중 요양보호사에게 월,목 전달되는 신문
  JOB_ALARM_OFF = 'job_alarm(off)_2'.freeze # 구직의사 없음 요양보호사에게 매달 첫번째 월요일 오후 12시에 전달되는 신문
  JOB_ALARM_WORKING = 'job_alarm(working)_2'.freeze # 일하는 중인 요양보호사에게 매달 첫째주,셋째주 월요일 오후 12시에 전달되는 신문
  GAMIFICATION_MISSION_COMPLETE = 'plant_mission_complete'.freeze # 식물키우기 미션달성 메세지 발송
end