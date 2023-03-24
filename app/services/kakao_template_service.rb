class KakaoTemplateService
  MAX_ITEM_LIST_TEXT_LENGTH = 19.freeze

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
      get_personalized_data(tem_params)
    when KakaoTemplate::EXTRA_BENEFIT
      get_extra_benefit_data(tem_params)
    when KakaoTemplate::PROPOSAL_ACCEPTED
      get_proposal_accepted_data(tem_params)
    when KakaoTemplate::PROPOSAL_REJECTED
      get_proposal_rejected_data(tem_params)
    when KakaoTemplate::SATISFACTION_SURVEY
      get_satisfaction_survey_data(tem_params)
    when KakaoTemplate::USER_SATISFACTION_SURVEY
      get_user_satisfaction_survey_data(tem_params)
    when KakaoTemplate::USER_CALL_REMINDER
      get_user_call_reminder_data(tem_params)
    when KakaoTemplate::BUSINESS_CALL_REMINDER
      get_business_call_reminder_data(tem_params)
    else
      # Sentry.capture_message("존재하지 않는 메시지 템플릿 요청입니다: template_id: #{template_id}, tem_params: #{tem_params.to_json}")
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

  def get_visit_job_posting_data(tem_params)
    {
      title: "#{tem_params[:distance]} 거리의 일자리 알림 도착!",
      message: "신규 일자리 알림\n#{tem_params[:distance]} 거리의 일자리 알림 도착!\n\n≫ 근무시간: #{convert_safe_text(tem_params[:days_text])} #{convert_safe_text(tem_params[:hours_text])}\n≫ 근무지: #{tem_params[:address]}\n≫ 시급: #{convert_safe_text(tem_params[:pay_text])}\n≫ 어르신 정보: #{tem_params[:grade] || "미상등급"}/#{tem_params[:age] || "미상연"}세/#{tem_params[:gender]}\n\n아래 버튼 또는 링크를 클릭해서 자세한 내용 확인하고 지원해보세요!\ncarepartner.kr#{tem_params[:path]}\n\n전화: ☎#{tem_params[:vn]}\n\n(본 공고 취업 시 5만원의 취업축하수당 지급!)",
      buttons: [
        {
          name: "채용공고 확인하기",
          type: "WL",
          url_mobile: tem_params[:origin_url],
          url_pc: tem_params[:origin_url],
        },
        {
          name: "알림 설정",
          type: "WL",
          url_mobile: "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_homecare_short",
          url_pc: "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_homecare_short"
        }
      ]
    }
  end

  def get_facility_job_posting_data(tem_params)
    {
      title: "#{tem_params[:distance]} 거리의 일자리 알림 도착!",
      message: "신규 일자리 알림\n#{tem_params[:distance]} 거리의 일자리 알림 도착!\n\n≫ 근무시간: #{convert_safe_text(tem_params[:days_text])} #{convert_safe_text(tem_params[:hours_text])}\n≫ 근무지: #{tem_params[:address]}\n≫ 시급: #{convert_safe_text(tem_params[:pay_text])}\n≫ 어르신 정보: #{tem_params[:grade] || "미상등급"}/#{tem_params[:age] || "미상연"}세/#{tem_params[:gender]}\n\n아래 버튼 또는 링크를 클릭해서 자세한 내용 확인하고 지원해보세요!\ncarepartner.kr#{tem_params[:path]}\n\n전화: ☎#{tem_params[:vn]}\n\n(본 공고 취업 시 5만원의 취업축하수당 지급!)",
      buttons: [
        {
          name: "채용공고 확인하기",
          type: "WL",
          url_mobile: tem_params[:origin_url],
          url_pc: tem_params[:origin_url],
        },
        {
          name: "알림 설정",
          type: "WL",
          url_mobile: "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_homecare_short",
          url_pc: "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_homecare_short"
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
      message: "안녕하세요 #{tem_params[:business_name]} 담당자님,\n\n요양보호사님의 채용여부는 결정되었나요?\n케어파트너에게 채용경험을 들려주세요.\n(공고명: #{tem_params[:job_posting_title]})\n\n아래 버튼을 눌러 1분 채용결과 조사에 참여해주세요.\n매주 추첨을 통해 커피 쿠폰을 드립니다.\n(여러 번 참여하면 당첨 확률 상승!)\n#{tem_params[:link]}",
      buttons: [
        {
          name: "설문조사 참여하기",
          type: "WL",
          url_mobile: "https://business.carepartner.kr/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=satisfaction_survey_follow_up",
          url_pc: "https://business.carepartner.kr/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=satisfaction_survey_follow_up",
        },
      ]
    }
  end

  def get_user_satisfaction_survey_data(tem_params)
    {
      title: "#{tem_params[:user_name]}님 취직여부는 결정되었나요?",
      message: "안녕하세요 #{tem_params[:user_name]} 님,\n\n방금 통화하신 기관의 공고에서 일자리를 구하셨나요?\n케어파트너에게 일자리 찾기 경험을 들려주세요.\n(공고명: #{tem_params[:job_posting_title]})\n\n아래 버튼을 눌러 1분 채용결과 조사에 참여해주세요.\n매주 추첨을 통해 커피 쿠폰을 드립니다.\n(여러 번 참여하면 당첨 확률 상승!)\n#{tem_params[:link]}",
      buttons: [
        {
          name: "설문조사 참여하기",
          type: "WL",
          url_mobile: "https://www.carepartner.kr/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=satisfaction_survey_follow_up",
          url_pc: "https://www.carepartner.kr/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&utm_source=message&utm_medium=arlimtalk&utm_campaign=satisfaction_survey_follow_up",
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

  def good_number(phone_number)
    if phone_number&.length == 12
      phone_number&.scan(/.{4}/)&.join('-')
    else
      phone_number&.slice(0, 3) + "-" +  phone_number&.slice(3..)&.scan(/.{4}/)&.join('-') rescue nil
    end
  end

  def convert_safe_text(text, empty_string = "정보없음")
    text.presence&.truncate(MAX_ITEM_LIST_TEXT_LENGTH) || empty_string
  end
end