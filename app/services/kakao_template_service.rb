class KakaoTemplateService
  MAX_ITEM_LIST_TEXT_LENGTH = 19.freeze
  SETTING_ALARM_LINK = "https://www.carepartner.kr/users/edit?utm_source=message&utm_medium=arlimtalk&utm_campaign="
  ALARM_POSITION_LINK = "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign="

  attr_reader :template_id

  def initialize(template_id)
    @template_id = template_id
  end

  private

  def get_template_data(template_id, tem_params)
    case template_id
    when KakaoTemplate::PROPOSAL
      get_proposal_data(tem_params)
    when KakaoTemplate::NEW_JOB_POSTING_VISIT
      get_visit_job_posting_data(tem_params)
    when KakaoTemplate::NEW_JOB_POSTING_FACILITY
      get_facility_job_posting_data(tem_params)
    when KakaoTemplate::PERSONALIZED
      get_personalized_data_by_json(tem_params)
    when KakaoTemplate::EXTRA_BENEFIT
      get_extra_benefit_data_by_json(tem_params)
    when KakaoTemplate::PROPOSAL_ACCEPTED
      get_proposal_accepted_data(tem_params)
    when KakaoTemplate::PROPOSAL_REJECTED
      get_proposal_rejected_data(tem_params)
    when KakaoTemplate::PROPOSAL_RESPONSE_EDIT
      get_proposal_response_edit_data(tem_params)
    when KakaoTemplate::SATISFACTION_SURVEY
      get_satisfaction_survey_data(tem_params)
    when KakaoTemplate::USER_SATISFACTION_SURVEY
      get_user_satisfaction_survey_data(tem_params)
    when KakaoTemplate::USER_CALL_REMINDER
      get_user_call_reminder_data(tem_params)
    when KakaoTemplate::BUSINESS_CALL_REMINDER
      get_business_call_reminder_data(tem_params)
    when KakaoTemplate::CALL_REQUEST_ALARM
      get_new_apply_data(tem_params)
    when KakaoTemplate::BUSINESS_CALL_APPLY_USER_REMINDER
      get_apply_user_call_reminder_data(tem_params)
    when KakaoTemplate::JOB_ALARM_ACTIVELY
      get_job_alarm_actively(tem_params)
    when KakaoTemplate::JOB_ALARM_COMMON
      get_job_alarm_commonly(tem_params)
    when KakaoTemplate::JOB_ALARM_OFF
      get_job_alarm_off(tem_params)
    when KakaoTemplate::JOB_ALARM_WORKING
      get_job_alarm_working(tem_params)
    when KakaoTemplate::GAMIFICATION_MISSION_COMPLETE
      get_gamification_mission_complete
    when KakaoTemplate::CONTRACT_AGENCY_ALARM
      get_contract_agency_alarm(tem_params)
    when KakaoTemplate::CONTRACT_AGENCY_ALARM_EDIT2
      get_contract_agency_alarm_edit2(tem_params)
    when KakaoTemplate::CAREER_CERTIFICATION
      get_career_certification_alarm(tem_params)
    when KakaoTemplate::CLOSE_JOB_POSTING_NOTIFICATION
      get_close_job_posting_notification(tem_params)
    when KakaoTemplate::CANDIDATE_RECOMMENDATION
      get_candidate_recommendation(tem_params)
    when KakaoTemplate::SIGNUP_COMPLETE_GUIDE
      get_signup_complete_guide
    when KakaoTemplate::HIGH_SALARY_JOB
      get_high_salary_job(tem_params)
    when KakaoTemplate::ENTER_LOCATION
      get_enter_location(tem_params)
    else
      Jets.logger.info "존재하지 않는 메시지 템플릿 요청입니다: template_id: #{template_id}, tem_params: #{tem_params.to_json}"
    end
  end

  def get_proposal_data(tem_params)
    items = {
      itemHighlight: {
        title: "#{tem_params[:user_name]}님! 제안 내용을 확인하고 응답해주세요",
        description: '인기 공고는 빠르게 마감됩니다'
      },
      item: {
        list: [
          {
            title: '센터명',
            description: convert_safe_text(tem_params[:business_name])
          },
          {
            title: '거리',
            description: convert_safe_text(tem_params[:distance])
          },
          {
            title: '근무지',
            description: convert_safe_text(tem_params[:address])
          },
          {
            title: '근무유형',
            description: convert_safe_text(tem_params[:work_type_ko])
          },
          {
            title: '임금조건',
            description: convert_safe_text(tem_params[:pay_text])
          },
        ],
        summary: ""
      }
    }
    {
      title: "#{tem_params[:user_name]}님, 가까운 센터에서 일자리를 제안했어요!",
      message: "#{tem_params[:business_name]}에서 #{tem_params[:user_name]}님에게 일자리 제안을 보냈습니다.\n(7일 내 응답하지 않으면 자동 거절됩니다)\n\n본 공고에 취업하시면 5만원의 취업축하금을 드려요!\n\n[아래 버튼을 눌러 상세공고를 확인하시고 수락 여부를 결정해주세요]\n센터번호: #{good_number(tem_params[:business_vn])}",
      img_url: "https://mud-kage.kakao.com/dn/btfYkj/btrXIoI2ckc/85jhQdX5TuqNEdfrfBXgX0/img_l.jpg",
      items: items,
      buttons: [
        {
          name: "일자리 제안 확인하기",
          type: "WL",
          url_mobile: "https://carepartner.kr/jobs/#{tem_params[:job_posting_public_id]}?proposal=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=job_proposal_response"
        },
      ]
    }
  end

  def get_proposal_response_edit_data(tem_params)
    return {
      title: '가까운 거리의 일자리 제안 도착!',
      message: "[케어파트너] 가까운 거리의 일자리 제안 도착!

#{tem_params[:business_name]}에서 #{tem_params[:user_name]}님에게 일자리 제안을 보냈습니다.

≫ 거리: #{tem_params[:distance]}
≫ 근무지: #{tem_params[:address]}
≫ 근무유형: #{tem_params[:work_type_ko]}
≫ 임금조건: #{tem_params[:pay_text]}

(7일 내 응답하지 않으면 자동 거절됩니다)

센터번호: #{tem_params[:business_vn]}",
      buttons: [
        {
          name: "일자리 제안 확인하기",
          type: "WL",
          url_mobile: "https://carepartner.kr/jobs/#{tem_params[:job_posting_public_id]}?proposal=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=job_proposal_response(edit)",
          url_pc: "https://carepartner.kr/jobs/#{tem_params[:job_posting_public_id]}?proposal=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=job_proposal_response(edit)"
        }
      ]
    }
  end

  def get_visit_job_posting_data(tem_params)
    daysAndHours = "≫ 근무시간: #{convert_safe_text(tem_params[:days_text])} #{convert_safe_text(tem_params[:hours_text])}"
    address = "≫ 근무지: #{convert_safe_text(tem_params[:address])}"
    pay = "≫ 급여: #{convert_safe_text(tem_params[:pay_text])}"
    customer_info = "≫ 어르신 정보: #{convert_safe_text(tem_params[:customer_grade])}/#{convert_safe_text(tem_params[:customer_age])}세/#{convert_safe_text(tem_params[:customer_gender])}"
    call = "전화: ☎#{convert_safe_text(tem_params[:business_vn])}"
    bottomText = "아래 버튼 또는 링크를 클릭해서 자세한 내용 확인하고 지원해보세요!\ncarepartner.kr#{tem_params[:path]}\n\n#{call}"
    settingAlarmLink = "https://www.carepartner.kr/users/edit?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_homecare_recent"
    settingAlarmPositionLink = "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_homecare_recent2"

    return {
      title: tem_params[:title],
      message: "[케어파트너] 신규일자리 알림\n#{call}\n\n#{daysAndHours}\n#{address}\n#{pay}\n#{customer_info}\n\n#{bottomText}",
      buttons: [
        {
          name: "일자리 확인하기",
          type: "WL",
          url_mobile: tem_params[:origin_url],
          url_pc: tem_params[:origin_url],
        },
        {
          name: "전화하기",
          type: "AL",
          scheme_ios: "tel://#{convert_safe_text(tem_params[:business_vn])}",
          scheme_android: "tel://#{convert_safe_text(tem_params[:business_vn])}",
        },
        {
          name: "알림 설정",
          type: "WL",
          url_mobile: settingAlarmLink,
          url_pc: settingAlarmLink
        },
        {
          name: "알림 지역 설정",
          type: "WL",
          url_mobile: settingAlarmPositionLink,
          url_pc: settingAlarmPositionLink
        }
      ]
    }
  end

  def get_facility_job_posting_data(tem_params)
    daysAndHours = "≫ 근무시간: #{convert_safe_text(tem_params[:days_text])} #{convert_safe_text(tem_params[:hours_text])}"
    address = "≫ 근무지: #{convert_safe_text(tem_params[:address])}"
    pay = "≫ 급여: #{convert_safe_text(tem_params[:pay_text])}"
    customer_info = "≫ 어르신 정보: #{convert_safe_text(tem_params[:customer_grade])}/#{convert_safe_text(tem_params[:customer_age])}세/#{convert_safe_text(tem_params[:customer_gender])}"
    call = "전화: ☎#{convert_safe_text(tem_params[:business_vn])}"
    bottomText = "아래 버튼 또는 링크를 클릭해서 자세한 내용 확인하고 지원해보세요!\ncarepartner.kr#{tem_params[:path]}\n\n#{call}"
    settingAlarmLink = "https://www.carepartner.kr/users/edit?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_facility_recent"
    settingAlarmPositionLink = "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_facility_recent2"

    return {
      title: tem_params[:title],
      message: "[케어파트너] 신규일자리 알림\n#{call}\n\n#{daysAndHours}\n#{address}\n#{pay}\n#{customer_info}\n\n#{bottomText}",
      buttons: [
        {
          name: "일자리 확인하기",
          type: "WL",
          url_mobile: tem_params[:origin_url],
          url_pc: tem_params[:origin_url],
        },
        {
          name: "전화하기",
          type: "AL",
          scheme_ios: "tel://#{convert_safe_text(tem_params[:business_vn])}",
          scheme_android: "tel://#{convert_safe_text(tem_params[:business_vn])}",
        },
        {
          name: "알림설정",
          type: "WL",
          url_mobile: settingAlarmLink,
          url_pc: settingAlarmLink
        },
        {
          name: "알림 지역 설정",
          type: "WL",
          url_mobile: settingAlarmPositionLink,
          url_pc: settingAlarmPositionLink
        }
      ]
    }
  end

  def get_personalized_data(tem_params)
    items = {
      itemHighlight: {
        title: "#{tem_params[:distance]} 내 일자리 #{tem_params[:job_postings_count]} 건 추천",
        description: '맞춤 일자리 추천'
      },
      item: {
        list: [
          {
            title: '방문요양구인',
            description: convert_safe_text(tem_params[:visit_job_postings_count], "0 건")
          },
          {
            title: '입주요양구인',
            description: convert_safe_text(tem_params[:resident_job_postings_count], "0 건")
          },
          {
            title: '시설요양구인',
            description: convert_safe_text(tem_params[:facility_job_postings_count], "0 건")
          },
        ]
      }
    }
    {
      title: "케어파트너 맞춤 일자리 알림",
      message: "안녕하세요 #{tem_params[:user_name]} 선생님!\n\n설정하신 #{tem_params[:distance]} 내 #{tem_params[:job_postings_count]}건의 맞춤 일자리가 요양보호사님을 찾고 있어요.\n\n아래 링크를 클릭하여, 원하는 조건에 맞는 일자리를 확인해보세요!\ncarepartner.kr#{tem_params[:path]}",
      img_url: "https://mud-kage.kakao.com/dn/gNExl/btrX3r6mcbV/vpgICckvJ0EuF1JNdOVB7k/img_l.jpg",
      items: items,
      buttons: [
        {
          name: "케어파트너 바로가기",
          type: "WL",
          url_mobile: tem_params[:original_url],
        },
        {
          name: "알림 설정",
          type: "WL",
          url_mobile: "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=personalized_job"
        }
      ]
    }
  end

  def get_personalized_data_by_json(tem_params)
    items = {
      itemHighlight: {
        title: "#{tem_params["distance"]} 내 일자리 #{tem_params["job_postings_count"]} 건 추천",
        description: '맞춤 일자리 추천'
      },
      item: {
        list: [
          {
            title: '방문요양구인',
            description: convert_safe_text(tem_params["visit_job_postings_count"], "0 건")
          },
          {
            title: '입주요양구인',
            description: convert_safe_text(tem_params["resident_job_postings_count"], "0 건")
          },
          {
            title: '시설요양구인',
            description: convert_safe_text(tem_params["facility_job_postings_count"], "0 건")
          },
        ]
      }
    }
    {
      title: "케어파트너 맞춤 일자리 알림",
      message: "안녕하세요 #{tem_params["user_name"]} 선생님!\n\n설정하신 #{tem_params["distance"]} 내 #{tem_params["job_postings_count"]}건의 맞춤 일자리가 요양보호사님을 찾고 있어요.\n\n아래 링크를 클릭하여, 원하는 조건에 맞는 일자리를 확인해보세요!\ncarepartner.kr#{tem_params["path"]}",
      img_url: "https://mud-kage.kakao.com/dn/gNExl/btrX3r6mcbV/vpgICckvJ0EuF1JNdOVB7k/img_l.jpg",
      items: items,
      buttons: [
        {
          name: "케어파트너 바로가기",
          type: "WL",
          url_mobile: tem_params["original_url"],
        },
        {
          name: "알림 설정",
          type: "WL",
          url_mobile: "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=personalized_job"
        }
      ]
    }
  end

  def get_extra_benefit_data(tem_params)
    items = {
      itemHighlight: {
        title: "#{tem_params[:distance]} 추가수당 일자리 #{tem_params[:job_postings_count]} 추천",
        description: '인기공고는 빠르게 마감됩니다.'
      },
      item: {
        list: [
          {
            title: '취업축하금',
            description: convert_safe_text(tem_params[:cpt_job_postings_count], "0 건")
          },
          {
            title: '가산수당',
            description: convert_safe_text(tem_params[:benefit_job_postings_count], "0 건")
          },
        ]
      }
    }
    {
      title: "케어파트너 맞춤 일자리 알림",
      message: "안녕하세요 #{tem_params[:user_name]} 선생님\n\n요청하신 지역의 #{tem_params[:distance]} 거리의 일자리 추천드려요.\n50,000원의 취업축하금 또는 일 3,000원의 가산수당을 받을 수 있어요!\n\n아래 링크를 클릭하여, 일자리를 확인해보세요\ncarepartner.kr#{tem_params[:path]}",
      img_url: "https://mud-kage.kakao.com/dn/bEFFfY/btrX4lZueKC/WORpJClzQ6UKvpRXt5SzM1/img_l.jpg",
      items: items,
      buttons: [
        {
          name: "케어파트너 바로가기",
          type: "WL",
          url_mobile: tem_params[:original_url],
        },
        {
          name: "알림 설정",
          type: "WL",
          url_mobile: "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=extra_benefits_job"
        }
      ]
    }
  end

  def get_extra_benefit_data_by_json(tem_params)
    items = {
      itemHighlight: {
        title: "#{tem_params["distance"]} 추가수당 일자리 #{tem_params["job_postings_count"]} 추천",
        description: '인기공고는 빠르게 마감됩니다.'
      },
      item: {
        list: [
          {
            title: '취업축하금',
            description: convert_safe_text(tem_params.dig("cpt_job_postings_count"), "0 건")
          },
          {
            title: '가산수당',
            description: convert_safe_text(tem_params.dig("benefit_job_postings_count"), "0 건")
          },
        ]
      }
    }
    {
      title: "케어파트너 맞춤 일자리 알림",
      message: "안녕하세요 #{tem_params["user_name"]} 선생님\n\n요청하신 지역의 #{tem_params["distance"]} 거리의 일자리 추천드려요.\n50,000원의 취업축하금 또는 일 3,000원의 가산수당을 받을 수 있어요!\n\n아래 링크를 클릭하여, 일자리를 확인해보세요\ncarepartner.kr#{tem_params["path"]}",
      img_url: "https://mud-kage.kakao.com/dn/bEFFfY/btrX4lZueKC/WORpJClzQ6UKvpRXt5SzM1/img_l.jpg",
      items: items,
      buttons: [
        {
          name: "케어파트너 바로가기",
          type: "WL",
          url_mobile: tem_params["original_url"],
        },
        {
          name: "알림 설정",
          type: "WL",
          url_mobile: "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=extra_benefits_job"
        }
      ]
    }
  end

  def get_proposal_accepted_data(tem_params)
    items = {
      itemHighlight: {
        title: "#{tem_params[:business_name]} 담당자님 제안이 수락되었습니다",
        description: '빠르게 연락해서 일자리를 제안하세요'
      },
      item: {
        list: [
          {
            title: '공고명',
            description: convert_safe_text(tem_params[:job_posting_title])
          },
          {
            title: '요양보호사',
            description: convert_safe_text(tem_params[:user_name])
          },
          {
            title: '나이',
            description: convert_safe_text(tem_params[:age])
          },
          {
            title: '거주지',
            description: convert_safe_text(tem_params[:address])
          },
          {
            title: '경력',
            description: convert_safe_text(tem_params[:career])
          },
          {
            title: '자기소개',
            description: convert_safe_text(tem_params[:self_introduce])
          },
        ]
      }
    }
    {
      title: "#{tem_params[:business_name]} 담당자님 제안이 수락되었습니다.",
      message: "[아래 버튼 혹은 링크를 눌러 요양보호사의 정보를 확인하고 직접 전화해보세요]\n\n빠르게 연락할수록 채용확률이 높아집니다.\n\n#{tem_params[:link]}",
      items: items,
      buttons: [
        {
          name: "전화번호 확인하기",
          type: "WL",
          url_mobile: "https://business.carepartner.kr/proposals/#{tem_params[:proposal_id]}?auth_token=#{tem_params[:auth_token]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=proposal_accepted",
          url_pc: "https://business.carepartner.kr/proposals/#{tem_params[:proposal_id]}?auth_token=#{tem_params[:auth_token]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=proposal_accepted"
        },
      ]
    }
  end

  def get_proposal_rejected_data(tem_params)
    items = {
      itemHighlight: {
        title: "#{tem_params[:business_name]} 담당자님 제안이 거절되었습니다.",
        description: '다른 요양보호사를 찾아보세요'
      },
      item: {
        list: [
          {
            title: '공고명',
            description: convert_safe_text(tem_params[:job_posting_title])
          },
          {
            title: '요양보호사',
            description: convert_safe_text(tem_params[:user_name])
          },
          {
            title: '나이',
            description: convert_safe_text(tem_params[:age])
          },
          {
            title: '거주지',
            description: convert_safe_text(tem_params[:address])
          },
          {
            title: '경력',
            description: convert_safe_text(tem_params[:career])
          },
          {
            title: '자기소개',
            description: convert_safe_text(tem_params[:self_introduce])
          },
        ]
      }
    }
    {
      title: "#{tem_params[:business_name]} 담당자님 제안이 수락되었습니다.",
      message: "다른 요양보호사들이 일자리 제안을 기다리고 있어요.\n\n[아래 버튼을 눌러 다른 요양보호사들을 확인하고 일자리를 제안해보세요]",
      items: items,
      buttons: [
        {
          name: "다른 요양보호사 찾기",
          type: "WL",
          url_mobile: "https://business.carepartner.kr/recruitment_management/users/#{tem_params[:job_posting_public_id]}&utm_source=message&utm_medium+arlimtalk&utm_campaign=proposal_refused",
        },
      ]
    }
  end

  def get_satisfaction_survey_data(tem_params)
    {
      title: "#{tem_params[:business_name]} 담당자님 채용여부는 결정되었나요?",
      message: "안녕하세요, #{tem_params[:business_name]} 담당자님\n조금 전 요양보호사와의 통화는 어떠셨나요?\n≫ 공고명: #{tem_params[:job_posting_title]}\n\n아래 버튼을 눌러 1분 채용결과 조사에 참여해주세요.\n매주 추첨을 통해 커피 쿠폰을 드립니다.\n여러 번 참여하면 당첨 확률 상승!\n#{tem_params[:link]}",
      buttons: [
        {
          name: "설문조사 참여하기",
          type: "WL",
          url_mobile: "https://business.carepartner.kr/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=business_satisfaction_survey",
          url_pc: "https://business.carepartner.kr/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=business_satisfaction_survey",
        },
      ]
    }
  end

  def get_user_satisfaction_survey_data(tem_params)
    return {
      message: "안녕하세요, #{tem_params[:user_name]} 님\n방금 통화하신 공고의 일자리를 구하셨나요?\n≫ 공고명: #{tem_params[:job_posting_title]}\n\n아래 버튼을 눌러 1분 취업결과 조사에 참여해주세요.\n매주 추첨을 통해 커피 쿠폰을 드립니다.\n여러 번 참여하면 당첨 확률 상승!\n#{tem_params[:link]}\n\n※설문 미참여시 취업지원금 대상에서 제외됩니다",
      buttons: [
        {
          name: "설문조사 참여하기",
          type: "WL",
          url_mobile: "https://www.carepartner.kr/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=user_satisfaction_survey",
          url_pc: "https://www.carepartner.kr/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=user_satisfaction_survey",
        },
      ]
    }
  end

  def get_user_call_reminder_data(tem_params)
    {
      title: "[케어파트너] 부재중전화 알림",
      message: "[케어파트너] 부재중전화 알림\n#{tem_params[:user_name]}님, 제안을 보낸 #{tem_params[:business_name]}에서 걸려온 부재중 전화가 있습니다.\n아래 번호로 센터에 전화해보세요.\n\n빠르게 연락할수록 채용확률이 높아집니다.\n\n≫ 공고명: #{tem_params[:job_posting_title]}\n☎ 번호: #{tem_params[:business_vn]}\n\n*전화를 받지 않는 경우 문자를 남겨보세요.",
    }
  end

  def get_business_call_reminder_data(tem_params)
    {
      title: "[케어파트너] 부재중전화 알림",
      message: "[케어파트너] 부재중전화 알림\n#{tem_params[:business_name]} 담당자님, 등록하신 공고를 통해 #{tem_params[:user_name]} 요양보호사에게 걸려온 부재중 전화가 있습니다.\n최근 전화 기록을 확인하여 전화해보세요.\n\n빠르게 연락할수록 채용확률이 높아집니다.\n\n≫ 공고명: #{tem_params[:job_posting_title]}\n≫ 부재중시간: #{tem_params[:called_at]}\n\n*전화를 받지 않는 경우 문자를 남겨보세요.",
    }
  end

  def get_apply_user_call_reminder_data(tem_params)
    {
      title: "[케어파트너] 부재중전화 알림",
      message: "[케어파트너] 부재중전화 알림\n#{tem_params[:user_name]}님, 전화상담 신청하신 #{tem_params[:business_name]}에서 걸려온 부재중 전화가 있습니다.\n아래 번호로 센터에 전화해보세요.\n\n빠르게 연락할수록 채용확률이 높아집니다.\n\n≫ 공고명: #{tem_params[:job_posting_title]}\n☎ 번호: #{tem_params[:business_vn]}\n\n*전화를 받지 않는 경우 문자를 남겨보세요.",
    }
  end

  def get_new_apply_data(tem_params)
    {
      title: "[케어파트너] 전화요청 알림",
      message: "[케어파트너] 전화요청 알림\n#{tem_params[:business_name]} 담당자님, 등록하신 공고에 전화를 요청한 요양보호사가 있습니다.\n아래 버튼 혹은 링크를 눌러 요양보호사 정보를 확인하고 전화해보세요.\n\n빠르게 연락할수록 채용확률이 높아집니다.\n\n공고명: #{tem_params[:job_posting_title]}\n링크: #{tem_params[:short_url]}",
      buttons: [
        {
          name: "전화번호 확인하기",
          type: "WL",
          url_mobile: "https://business.carepartner.kr/employment_management/applies/#{tem_params[:apply_id]}?auth_token=#{tem_params[:auth_token]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=call_request_alarm",
          url_pc: "https://business.carepartner.kr/employment_management/applies/#{tem_params[:apply_id]}?auth_token=#{tem_params[:auth_token]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=call_request_alarm",
        },
      ]
    }
  end

  def get_job_alarm_actively(tem_params)
    today = NewsPaper::get_today
    settingAlarmLink = "#{SETTING_ALARM_LINK}#{template_id}"
    alarmPositionLink = "#{ALARM_POSITION_LINK}#{template_id}"
    link = "https://www.carepartner.kr/newspaper?lat=#{tem_params["lat"]}&lng=#{tem_params["lng"]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=#{template_id}"
    {
      title: "[케어파트너] 일자리 신문",
      message: "#{today} 일자리 신문이 도착했어요.\n\n오늘의 일자리부터 날씨, 명언까지!\n\n케어파트너 일자리 신문과 함께 하루를 시작해보세요.\n\n👇'신문 확인하기' 버튼 클릭👇",
      buttons: [
        {
          name: "신문 확인하기",
          type: "WL",
          url_mobile: link,
          url_pc: link,
        },
        {
          name: "알림 설정",
          type: "WL",
          url_mobile: settingAlarmLink,
          url_pc: settingAlarmLink
        },
      # {
      #   name: "알림 지역 설정",
      #   type: "WL",
      #   url_mobile: alarmPositionLink,
      #   url_pc: alarmPositionLink
      # }
      ]
    }
  end

  def get_job_alarm_commonly(tem_params)
    today = NewsPaper::get_today
    settingAlarmLink = "#{SETTING_ALARM_LINK}#{template_id}"
    alarmPositionLink = "#{ALARM_POSITION_LINK}#{template_id}"
    link = "https://www.carepartner.kr/newspaper?lat=#{tem_params["lat"]}&lng=#{tem_params["lng"]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=#{template_id}"
    {
      title: "[케어파트너] 일자리 신문",
      message: "#{today} 일자리 신문이 도착했어요.\n\n최근 일자리부터 날씨, 명언까지!\n\n케어파트너 일자리 신문과 함께 하루를 시작해보세요.\n\n👇'신문 확인하기' 버튼 클릭👇",
      buttons: [
        {
          name: "신문 확인하기",
          type: "WL",
          url_mobile: link,
          url_pc: link,
        },
        {
          name: "더 자주 받아볼래요",
          type: "WL",
          url_mobile: settingAlarmLink,
          url_pc: settingAlarmLink
        },
      # {
      #   name: "알림 지역 설정",
      #   type: "WL",
      #   url_mobile: alarmPositionLink,
      #   url_pc: alarmPositionLink
      # }
      ]
    }
  end

  def get_job_alarm_off(tem_params)
    settingAlarmLink = "#{SETTING_ALARM_LINK}#{template_id}"
    alarmPositionLink = "#{ALARM_POSITION_LINK}#{template_id}"
    link = "https://www.carepartner.kr/newspaper?lat=#{tem_params[:lat]}&lng=#{tem_params[:lng]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=#{template_id}"
    {
      title: "[케어파트너] 일자리 신문",
      message: "현재 일자리를 찾고 있지 않으시더라도, 좋은 공고가 있어 선생님께 소개드려요 ^^\n\n가벼운 마음으로 케어파트너 최근 일자리 살펴보세요 ~!\n\n👇'일자리 둘러보기' 버튼 클릭👇",
      buttons: [
        {
          name: "일자리 둘러보기",
          type: "WL",
          url_mobile: link,
          url_pc: link,
        },
        {
          name: "더 자주 일자리 받아볼래요",
          type: "WL",
          url_mobile: settingAlarmLink,
          url_pc: settingAlarmLink
        },
        {
          name: "알림 지역 설정",
          type: "WL",
          url_mobile: alarmPositionLink,
          url_pc: alarmPositionLink
        }
      ]
    }
  end

  def get_job_alarm_working(tem_params)
    settingAlarmLink = "#{SETTING_ALARM_LINK}#{template_id}"
    alarmPositionLink = "#{ALARM_POSITION_LINK}#{template_id}"
    link = "https://www.carepartner.kr/newspaper?lat=#{tem_params[:lat]}&lng=#{tem_params[:lng]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=#{template_id}"
    {
      title: "[케어파트너] 일자리 신문",
      message: "현재 일자리가 만족스럽지 않으신가요?\n추가 일자리를 구하고 싶으신가요?\n\n케어파트너에서 더 좋은 일자리들을 소개해드릴게요!\n\n👇'일자리 둘러보기' 버튼 클릭👇",
      buttons: [
        {
          name: "일자리 둘러보기",
          type: "WL",
          url_mobile: link,
          url_pc: link,
        },
        {
          name: "더 자주 일자리 받아볼래요",
          type: "WL",
          url_mobile: settingAlarmLink,
          url_pc: settingAlarmLink
        },
        {
          name: "알림 지역 설정",
          type: "WL",
          url_mobile: alarmPositionLink,
          url_pc: alarmPositionLink
        }
      ]
    }
  end

  def get_gamification_mission_complete
    link = "https://www.carepartner.kr/me/growth_game?proposal=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=plant_mission_complete"
    {
      title: "[미션달성] 식물에 물을 주세요 🌱",
      message: "[미션달성] 식물에 물을 주세요 🌱\n\n미션을 달성했어요!\n\n아래 버튼을 클릭하면 식물에 물을 줄 수 있어요 👇",
      buttons: [
        {
          name: "식물에 물주기",
          type: "WL",
          url_mobile: link,
          url_pc: link,
        }
      ]
    }
  end

  def get_contract_agency_alarm(tem_params)
    link = "https://business.carepartner.kr/contracts/agency/#{tem_params[:business_id]}?temp=aaa&utm_source=message&utm_medium=arlimtalk&utm_campaign=contract_agency_alarm"
    {
      title: "[무료] 근로계약서 대신 작성해드려요",
      message: "[무료] 근로계약서 대신 작성해드려요\n\n케어파트너에 게재한 공고 중 채용을 확정한 공고가 있나요?\n\n24시간 내에 기관과 요양보호사에게 각 1부씩 완성된 근로계약서를 보내드려요\n\n노무사에게 검토받은 근로계약서 혹은 직접 사용중인 근로계약서 중 선택할 수 있어요\n\n👇 아래 버튼을 눌러 근로계약서 대행 서비스를 신청해 보세요! 👇",
      buttons: [
        {
          name: "근로계약서 대행 신청",
          type: "WL",
          url_mobile: link,
          url_pc: link,
        }
      ]
    }
  end

  def get_contract_agency_alarm_edit2(tem_params)
    link = "https://business.carepartner.kr/contracts/agency/#{tem_params[:business_id]}?temp=aaa&utm_source=message&utm_medium=arlimtalk&utm_campaign=contract_agency_alarm(edit2)"
    {
      title: "비대면으로 근로계약서 서명받으세요",
      message: "[비대면으로 근로계약서 서명받으세요]

근로계약서에 서명 받아야 하는데, 요양보호사와 다시 만나기 번거로우신가요?
케어파트너가 대신 받아드릴게요.
직접 만나지 않아도 24시간이면 요양보호사 서명까지 완료된 근로계약서를 받아볼 수 있어요!

👇 아래 버튼을 눌러 근로계약서 서명 받기👇",
      buttons: [
        {
          name: "근로계약서 서명 신청",
          type: "WL",
          url_mobile: link,
          url_pc: link,
        }
      ]
    }
  end

  def get_career_certification_alarm(tem_params)
    {
      title: "[케어파트너] 경력인증 안내",
      message: "전화하셨던 공고의 일자리를 구하셨나요?

≫공고
#{tem_params[:job_posting_title]}

≫기관
#{tem_params[:center_name]}

≫ 경력자 인증이 궁금해요
케어파트너를 통한 취업 성공을 요양기관이 신뢰할 수 있도록 인증해 주는 제도예요

≫ 경력자 인증을 받으면 뭐가 좋나요?
다른 일자리를 구할 때 요양기관이 내 이력서를 보고 연락할 확률이 높아져요",
      buttons: [
        {
          name: '경력자 인증받기',
          type: 'WL',
          url_mobile: tem_params[:link],
          url_pc: tem_params[:link],
        }
      ]
    }
  end

  def get_close_job_posting_notification(tem_params)
    {
      title: "[케어파트너] 채용종료 안내",
      message: "'#{tem_params[:title]}' 공고의 채용이 종료되었나요?

공고를 ‘채용종료' 상태로 변경하면 요양보호사에게 즉시 전화할 수 있는 ≪무료 번호 열람권≫을 드려요.

(안내) 공고는 자동으로 종료되지 않아요.
채용을 종료하지 않으면 요양보호사들이 계속해서 연락할 수 있으니 꼭 채용을 종료해주세요!

👇 공고 채용 종료하기 클릭 👇",
      buttons: [
        {
          name: '공고 채용 종료하기',
          type: 'WL',
          url_mobile: tem_params[:link],
          url_pc: tem_params[:link],
        }
      ]
    }
  end

  def get_candidate_recommendation(tem_params)
    {
      title: '근무 가능 요일이 딱 맞는 요양보호사를 찾았어요!',
      message: "근무 가능 요일이 딱 맞는 요양보호사를 찾았어요!

공고 : #{tem_params[:job_posting_title]}

■ 기본 정보 : #{tem_params[:username]}/#{tem_params[:gender]}/#{tem_params[:age]}세
■ 구직 상태 : #{tem_params[:job_search_status]}
■ 이력서 제출 : #{tem_params[:resume_published_at]}
■ 경력 기간 : #{tem_params[:career]}

아래 버튼을 눌러 자세한 정보를 확인하고, 전화하거나 일자리를 제안해 보세요!",
      buttons: [
        {
          name: '맞춤 요양보호사 확인',
          type: 'WL',
          url_mobile: tem_params[:link],
          url_pc: tem_params[:link],
        }
      ]
    }
  end

  def get_signup_complete_guide
    find_work_link = "https://carepartner.kr/?utm_source=message&utm_medium=arlimtalk&utm_campaign=sign_up_complete_guide"
    help_work_link = "https://link.carepartner.kr/3QO0QRH"
    frequently_question_link = "https://link.carepartner.kr/3YBnG0E"
    alarm_setting = "https://www.carepartner.kr/users/edit?utm_source=message&utm_medium=arlimtalk&utm_campaign=sign_up_complete_guide_user_edit"

    {
      title: "[케어파트너] 가입 완료 안내",
      message: "환영합니다 선생님 :)
케어파트너 회원 가입이 완료되었어요.

선생님 댁 근처 요양일자리를 카카오톡 및 문자로 보내드릴게요.

≫ 한가지 더! 원하는 조건의 요양 일자리를 케어파트너에서 직접 찾아보고 지원하실 수도 있어요.

아래 버튼이나 링크를 눌러 궁금한 점을 지금 바로 해결해보세요👇",
      buttons: [
        {
          name: '일자리 찾아보기',
          type: 'WL',
          url_mobile: find_work_link,
          url_pc: find_work_link
        },
        {
          name: '취업 도움받기',
          type: 'WL',
          url_mobile: help_work_link,
          url_pc: help_work_link
        },
        {
          name: '자주 묻는 질문',
          type: 'WL',
          url_mobile: frequently_question_link,
          url_pc: frequently_question_link
        },
        {
          name: '알림 설정',
          type: 'WL',
          url_mobile: alarm_setting,
          url_pc: alarm_setting
        }
      ]
    }
  end

  def get_high_salary_job(tem_params)
    link1 = "https://www.carepartner.kr/users/after_sign_up?utm_source=message&utm_medium=arlimtalk&utm_campaign=high-salary-job-2"
    link2 = "https://pf.kakao.com/_xjwfcb/chat"

    {
      title: "[케어파트너] Draft 자격증 소지자 1일차",
      message: "#{tem_params[:name]} 선생님! 급여 높은 일자리 또는 원하시는 조건에 일자리를 찾고 계신가요?

전국 최대 규모 요양 일자리 서비스 케어파트너에서는 급여 높은 일자리를 쉽고 간편하게 확인해 보실 수 있습니다.

지금 바로 케어파트너에 접속하여 축하 포인트도 받으시고 급여 높은 일자리 알림도 무료로 받아보세요!

아래 버튼을 눌러 이용이 어려우신 부분에 대해 문의해 주시면 케어파트너 전문 상담사가 친절하게 알려드릴게요.",
      buttons: [
        {
          name: '높은 급여 일자리 알림받기',
          type: 'WL',
          url_mobile: link1,
          url_pc: link1
        },
        {
          name: '케어파트너 문의하기',
          type: 'WL',
          url_mobile: link2,
          url_pc: link2
        }
      ]
    }
  end

  def get_enter_location(tem_params)
    link1 = "https://www.carepartner.kr/users/after_sign_up?utm_source=message&utm_medium=arlimtalk&utm_campaign=enter-location"
    link2 = "https://pf.kakao.com/_xjwfcb/chat"

    {
      title: "[케어파트너] Draft 자격증 소지자 1일차 주소입력 이탈",
      message: "#{tem_params[:name]} 선생님의 주소가 입력되지 않았어요.

주소를 입력해 주시면 선생님께서 원하시는 조건에 맞는 일자리와 시급 높은 요양 일자리 정보를 무료로 알려드려요.

아래 버튼을 눌러 주소 입력 방법에 대해 문의해 주시면 케어파트너 상담사가 친절하게 알려드릴게요.",
      buttons: [
        {
          name: '주소 정보 입력하기',
          type: 'WL',
          url_mobile: link1,
          url_pc: link1
        },
        {
          name: '케어파트너 문의하기',
          type: 'WL',
          url_mobile: link2,
          url_pc: link2
        }
      ]
    }
  end

  def good_number(phone_number)
    if phone_number&.length == 12
      phone_number&.scan(/.{4}/)&.join('-')
    else
      phone_number&.slice(0, 3) + "-" + phone_number&.slice(3..)&.scan(/.{4}/)&.join('-') rescue nil
    end
  end

  def convert_safe_text(text, empty_string = "정보없음")
    text.presence&.truncate(MAX_ITEM_LIST_TEXT_LENGTH) || empty_string
  end

end