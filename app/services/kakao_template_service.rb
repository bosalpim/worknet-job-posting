class KakaoTemplateService
  include ApplicationHelper
  include MessageTemplateName
  include AlimtalkMessage
  DEFAULT_RESERVE_AT = "00000000000000".freeze
  MAX_ITEM_LIST_TEXT_LENGTH = 19.freeze
  SETTING_ALARM_LINK = "https://www.carepartner.kr/users/edit?utm_source=message&utm_medium=arlimtalk&utm_campaign="
  ALARM_POSITION_LINK = "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign="

  attr_reader :template_id, :message_type

  def initialize(template_id, message_type, phone, reserve_dt, alt_sms_btn_indexes = [])
    profile = ENV['KAKAO_BIZMSG_PROFILE']
    @template_id = template_id
    @message_type = message_type
    @profile = profile
    set_phone(phone)
    @reserve_dt = get_reserve_dt(reserve_dt)
    @sender_number = "15885877"
    @alt_sms_btn_indexes = alt_sms_btn_indexes
  end

  def get_final_request_params(tem_params, is_pre_pay = false, phone = nil)
    set_phone(phone) unless phone.nil?
    return nil if @phone.nil?

    template_data = get_template_data(tem_params)
    request_params = get_default_request_params(template_id, template_data, is_pre_pay)
    if (items = template_data[:items])
      request_params[:items] = items
    end
    sms_message = request_params[:message]
    if (buttons = template_data[:buttons])
      buttons.each_with_index do |btn, index|
        request_params["button#{index + 1}"] = btn
        if @alt_sms_btn_indexes.include?(index)
          sms_message += "\n\n"
          sms_message += btn[:name] + "↓"
          sms_message += "\n"
          sms_message += @template_id === MessageTemplateName::NEWSPAPER_V2 ? btn[:url_mobile] : ShortUrl.build(btn[:url_mobile]).url
        end
      end
    end
    if (quick_replies = template_data[:quick_replies])
      quick_replies.each_with_index do |quick_reply, index|
        request_params["quickReply#{index + 1}"] = quick_reply
      end
    end
    request_params[:sms_message] = sms_message
    request_params
  end

  def get_template_data(tem_params)
    case @template_id
    when MessageTemplateName::TARGET_USER_RESIDENT_POSTING
      get_target_user_resident_posting_data(tem_params)
    when MessageTemplateName::PROPOSAL_RESIDENT
      get_target_user_resident_proposal_data(tem_params)
    when MessageTemplateName::PROPOSAL
      get_proposal_data(tem_params)
    when MessageTemplateName::NEW_JOB_POSTING_VISIT
      get_visit_job_posting_data(tem_params)
    when MessageTemplateName::NEW_JOB_POSTING_FACILITY
      get_facility_job_posting_data(tem_params)
    when MessageTemplateName::PERSONALIZED
      get_personalized_data_by_json(tem_params)
    when MessageTemplateName::EXTRA_BENEFIT
      get_extra_benefit_data_by_json(tem_params)
    when MessageTemplateName::PROPOSAL_ACCEPT
      get_proposal_accept_data(tem_params)
    when MessageTemplateName::PROPOSAL_REJECTED
      get_proposal_rejected_data(tem_params)
    when MessageTemplateName::PROPOSAL_RESPONSE_EDIT
      get_proposal_response_edit_data(tem_params)
    when MessageTemplateName::SATISFACTION_SURVEY
      get_satisfaction_survey_data(tem_params)
    when MessageTemplateName::USER_SATISFACTION_SURVEY
      get_user_satisfaction_survey_data(tem_params)
    when MessageTemplateName::USER_CALL_REMINDER
      get_user_call_reminder_data(tem_params)
    when MessageTemplateName::MISSED_CAREGIVER_TO_BUSINESS_CALL
      get_missed_caregiver_to_business_call_data(tem_params)
    when MessageTemplateName::CALL_REQUEST_ALARM
      get_new_apply_data(tem_params)
    when MessageTemplateName::BUSINESS_CALL_APPLY_USER_REMINDER
      get_apply_user_call_reminder_data(tem_params)
    when MessageTemplateName::JOB_ALARM_ACTIVELY
      get_job_alarm_actively(tem_params)
    when MessageTemplateName::JOB_ALARM_COMMON
      get_job_alarm_commonly(tem_params)
    when MessageTemplateName::JOB_ALARM_OFF
      get_job_alarm_off(tem_params)
    when MessageTemplateName::JOB_ALARM_WORKING
      get_job_alarm_working(tem_params)
    when MessageTemplateName::GAMIFICATION_MISSION_COMPLETE
      get_gamification_mission_complete
    when MessageTemplateName::CAREER_CERTIFICATION
      get_career_certification_alarm(tem_params)
    when MessageTemplateName::CAREER_CERTIFICATION_V2
      get_career_certification_v2_alarm(tem_params)
    when MessageTemplateName::CLOSE_JOB_POSTING_NOTIFICATION
      get_close_job_posting_notification(tem_params)
    when MessageTemplateName::CANDIDATE_RECOMMENDATION
      get_candidate_recommendation(tem_params)
    when MessageTemplateName::SIGNUP_COMPLETE_GUIDE
      get_signup_complete_guide
    when MessageTemplateName::SIGNUP_COMPLETE_GUIDE3
      get_signup_complete_guide3
    when MessageTemplateName::HIGH_SALARY_JOB
      get_high_salary_job(tem_params)
    when MessageTemplateName::ENTER_LOCATION
      get_enter_location(tem_params)
    when MessageTemplateName::WELL_FITTED_JOB
      get_well_fitted_job(tem_params)
    when MessageTemplateName::CERTIFICATION_UPDATE
      get_certification_update(tem_params)
    when MessageTemplateName::POST_COMMENT
      get_post_comment(tem_params)
    when MessageTemplateName::CALL_INTERVIEW_PROPOSAL
      get_call_interview_proposal(tem_params)
    when MessageTemplateName::CALL_INTERVIEW_PROPOSAL_V2
      get_call_interview_proposal_v2(tem_params)
    when MessageTemplateName::CALL_SAVED_JOB_CAREGIVER
      get_call_saved_job_caregiver(tem_params)
    when MessageTemplateName::CALL_SAVED_JOB_POSTING_V2
      get_call_saved_job_posting_v2(tem_params)
    when MessageTemplateName::ASK_ACTIVE
      get_ask_active(tem_params)
    when MessageTemplateName::NEW_JOB_VISIT_V2
      get_new_job_visit_v2(tem_params)
    when MessageTemplateName::NEW_JOB_FACILITY_V2
      get_new_job_facility_v2(tem_params)
    when MessageTemplateName::NEWSPAPER_V2
      get_newspaper_v2(tem_params)
    when MessageTemplateName::NEW_JOB_POSTING
      get_new_job_posting(tem_params)
    when MessageTemplateName::CBT_DRAFT
      get_cbt_draft(tem_params)
    when MessageTemplateName::CAREPARTNER_PRESENT
      get_carepartner_draft(tem_params)
    when MessageTemplateName::ACCUMULATED_DRAFT
      get_accumulated_draft(tem_params)
    when MessageTemplateName::ACCUMULATED_PREPARATIVE
      get_accumulated_preparative(tem_params)
    when MessageTemplateName::CONNECT_RESULT_USER_SURVEY_A
      get_connect_result_user_survey_A(tem_params)
    when MessageTemplateName::CONNECT_RESULT_USER_SURVEY_B
      get_connect_result_user_survey_B(tem_params)
    when MessageTemplateName::JOB_APPLICATION
      get_job_application(tem_params)
    when MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO
      get_notify_free_job_posting_close_one_day_ago(tem_params)
    when MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE
      get_notify_free_job_posting_close(tem_params)
    when MessageTemplateName::ROULETTE
      get_roulette_ticket_receive(tem_params)
    when MessageTemplateName::CONTACT_MESSAGE
      get_contact_message(tem_params)
    when MessageTemplateName::CONFIRM_CAREER_CERTIFICATION
      get_confirm_career_certification_message(tem_params)
    when MessageTemplateName::BUSINESS_JOB_POSTING_COMPLETE
      get_business_job_posting_complete(tem_params)
    when MessageTemplateName::SMART_MEMO
      get_smart_memo_data(tem_params)
    when MessageTemplateName::TARGET_JOB_POSTING_PERFORMANCE
      get_target_job_posting_performance_data(tem_params)
    when MessageTemplateName::TARGET_JOB_POSTING_AD
      get_target_job_posting_ad_data(tem_params)
    when MessageTemplateName::TARGET_JOB_POSTING_AD_2
      get_target_job_posting_ad_2_data(tem_params)
    when MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY
      get_target_job_posting_ad_apply_data(tem_params)
    when MessageTemplateName::NONE_LTC_REQUEST
      get_none_ltc_request(tem_params)
    when MessageTemplateName::JOB_SUPPORT_REQUEST_AGREEMENT
      get_job_support_agreement(tem_params)
    when MessageTemplates[MessageNames::TARGET_USER_JOB_POSTING]
      get_target_user_job_posting_v2_data(tem_params)
    when MessageTemplateName::CAREER_CERTIFICATION_V3
      get_employment_confirmation_alarm(tem_params)
    else
      Jets.logger.info "존재하지 않는 메시지 템플릿 요청입니다: template_id: #{template_id}, tem_params: #{tem_params.to_json}"
    end
  end

  private

  def set_phone(phone)
    @phone = if Jets.env == 'production'
               phone
             elsif Main::Application::PHONE_NUMBER_WHITELIST.is_a?(Array) && Main::Application::PHONE_NUMBER_WHITELIST.include?(phone)
               phone
             else
               return nil
             end
  end

  def get_reserve_dt(reserve_dt)
    return DEFAULT_RESERVE_AT unless Jets.env.production?
    return reserve_dt if reserve_dt
    american_time = Time.current
    korean_offset = 9 * 60 * 60 # 9 hours ahead of American time
    korean_time = american_time + korean_offset

    if korean_time.hour >= 21
      next_day_time = korean_time + 1.day
      next_day_time.strftime("%Y%m%d") + "080000"
    elsif korean_time.hour < 8
      korean_time.strftime("%Y%m%d") + "080000"
    else
      DEFAULT_RESERVE_AT
    end
  end

  def current_time
    "#{Time.now.strftime("%y%m%d%H%M%S")}_#{SecureRandom.uuid.gsub('-', '')[0, 7]}"
  end

  def get_default_request_params(template_id, template_data, is_pre_pay)
    message, img_url, title = template_data.values_at(:message, :img_url, :title)
    data = if is_pre_pay
             {
               message_type: @message_type,
               phn: @phone.to_s.gsub(/[^0-9]/, ""),
               profile: @profile,
               tmplId: template_id,
               msg: message,
               smsKind: message&.bytesize&.to_i > 90 ? "L" : "S",
               msgSms: message,
               smsSender: @sender_number,
               smsLmsTit: title,
               img_url: img_url,
               reserveDt: @reserve_dt
             }
           else
             {
               msgid: "WEB#{current_time}",
               message_type: @message_type,
               profile_key: @profile,
               template_code: template_id,
               receiver_num: @phone.to_s.gsub(/[^0-9]/, ""),
               message: message,
               reserved_time: @reserve_dt,
               sms_title: title,
               sms_kind: message&.bytesize&.to_i > 90 ? "L" : "S",
               sender_num: @sender_number,
               image_url: img_url,
             }
           end

    title_required_templates = [
      MessageTemplateName::PROPOSAL_RESPONSE_EDIT,
      MessageTemplateName::NEW_JOB_POSTING_VISIT,
      MessageTemplateName::NEW_JOB_POSTING_FACILITY,
      MessageTemplateName::NEW_JOB_VISIT_V2,
      MessageTemplateName::NEW_JOB_FACILITY_V2,
      MessageTemplateName::NEW_JOB_POSTING
    ]

    if title_required_templates.include?(template_id)
      data[:title] = title
    end

    data
  end

  def get_target_user_job_posting_v2_data(tem_params)
    view_link = tem_params[:view_link]
    application_link = tem_params[:application_link]

    {
      title: tem_params[:title],
      message: tem_params[:message],
      buttons: [
        {
          name: '🔎 일자리 확인하기',
          type: 'WL',
          url_mobile: view_link
        },
        {
          name: '⚡️ 간편 지원하기',
          type: 'WL',
          url_mobile: application_link
        }
      ]
    }
  end

  def get_target_user_resident_proposal_data(tem_params)
    view_link = tem_params[:view_link]
    tel_link = tem_params[:tel_link]

    {
      title: tem_params[:title],
      message: tem_params[:message],
      buttons: [
        {
          name: '제안 내용 확인하기',
          type: 'WL',
          url_mobile: view_link
        },
        {
          name: '전화로 제안 수락하기',
          type: 'AL',
          scheme_ios: tel_link,
          scheme_android: tel_link
        }
      ]
    }
  end

  def get_target_user_resident_posting_data(tem_params)
    view_link = tem_params[:view_link]
    application_link = tem_params[:application_link]
    contact_link = tem_params[:contact_link]

    {
      title: tem_params[:title],
      message: tem_params[:message],
      buttons: [
        {
          name: '🔎 일자리 확인하기',
          type: 'WL',
          url_mobile: view_link
        },
        {
          name: '⚡️ 간편 지원하기',
          type: 'WL',
          url_mobile: application_link
        }
      ]
    }
  end

  def get_business_job_posting_complete(tem_params)
    base_url = business_base_url
    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@template_id}"

    {
      title: "공고등록 완료",
      message: "안녕하세요. 센터장님
#{tem_params[:job_posting_title]} 공고가 정상 등록되었어요.
등록한 공고를 주변 요양보호사에게 전달해 보세요.

■ 공고제목
#{tem_params[:job_posting_title]}

■ 공고를 전달해보세요.
케어파트너에 등록한 공고를 주변 요양보호사에게 빠르게 전달할 수 있어요. 공고 전달 시 3일 내 채용될 가능성이 높습니다.",
      buttons: [
        {
          name: "등록한 공고 전달하기",
          type: "WL",
          url_mobile: "#{base_url}/recruitment_management/#{tem_params[:job_posting_public_id]}/share?#{utm}",
          url_pc: "#{base_url}/recruitment_management/#{tem_params[:job_posting_public_id]}/share?#{utm}"
        }
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
    base_url = business_base_url
    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=business_call_survey"
    close_link = "#{base_url}/recruitment_management/#{tem_params[:job_posting_public_id]}/close?#{utm}"
    survey_link = "#{base_url}/satisfaction_surveys/#{tem_params[:job_posting_public_id]}/form?is_new=true&#{utm}"

    return {
      title: "방금 요양보호사와 통화한 공고가 아직 채용중 인가요?",
      message: "방금 요양보호사와 통화한 공고가 아직 채용중 인가요?

더 이상 채용하지 않는다면, 아래 ‘채용 종료하기' 버튼을 눌러주세요.

■ 공고
#{tem_params[:job_posting_title]}

(설문 참여 시 매주 추첨을 통해 커피 쿠폰을 드려요)",
      buttons: [
        {
          name: "채용종료하기",
          type: "WL",
          url_mobile: close_link,
          url_pc: close_link
        },
        {
          name: "설문조사 참여하기",
          type: "WL",
          url_mobile: survey_link,
          url_pc: survey_link
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

  # MISSED_CAREGIVER_TO_BUSINESS_CALL
  def get_missed_caregiver_to_business_call_data(tem_params)
    {
      title: "[케어파트너] 부재중전화 알림",
      message: "케어파트너를 통해 걸려온 부재중 전화가 있어요. 통화기록을 확인하고 전화해보세요.

■ 공고제목
#{tem_params[:job_posting_title]}

■ 전화문의한 요양보호사
#{tem_params[:user_name]}

■ 부재중 시간
#{tem_params[:called_at]}",
      buttons: [
        {
          name: "부재중 통화기록 확인",
          type: "WL",
          url_mobile: Main::Application::BUSINESS_URL + '/call-record?utm_source=message&utm_medium=arlimtalk&utm_campaign=missed_call_biz',
          url_pc: Main::Application::BUSINESS_URL + '/call-record?utm_source=message&utm_medium=arlimtalk&utm_campaign=missed_call_biz'
        }
      ]
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
          name: "알림 지역 설정",
          type: "WL",
          url_mobile: alarmPositionLink,
          url_pc: alarmPositionLink
        }
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
          name: "알림 지역 설정",
          type: "WL",
          url_mobile: alarmPositionLink,
          url_pc: alarmPositionLink
        }
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

  def get_career_certification_v2_alarm(tem_params)
    {
      title: "취업 성공하셨나요?",
      message: "≫ 공고
#{tem_params[:job_posting_title]}

≫ 기관
#{tem_params[:center_name]}

≫ 경력자 인증이 궁금해요
케어파트너를 통한 취업 성공을 요양기관이 신뢰할 수 있도록 인증해 주는 제도예요

≫ 경력자 인증을 받으면 뭐가 좋나요?
다른 일자리를 구할 때 요양기관이 내 이력서를 보고 연락할 확률이 높아져요",
      buttons: [
        {
          name: '취업 인증하기',
          type: 'WL',
          url_mobile: tem_params[:link],
          url_pc: tem_params[:link],
        }
      ]
    }
  end

  def get_employment_confirmation_alarm(tem_params)
    {
      title: "취업결과 알려주고 커피쿠폰 받아가세요",
      message: "≫ 공고
#{tem_params[:job_posting_title]}

≫ 기관
#{tem_params[:center_name]}

≫ [취업 확인]이란?
이전에 지원하신 기관에 취업 여부를 확인하고 있어요.

- 취업에 성공하셨다면, 취업 축하로 커피기프티콘 증정!
- 아직 구직중이시라면, 더 많은 일자리를 추천 드려요",
      buttons: [
        {
          name: '취업 인증하기',
          type: 'WL',
          url_mobile: tem_params[:link],
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

  def get_signup_complete_guide3
    getting_point_link = "https://www.carepartner.kr/me/point/newbie?utm_source=message&utm_medium=arlimtalk&utm_campaign=3000-point-first-invitefriend"
    find_work_link = "https://carepartner.kr/?utm_source=message&utm_medium=arlimtalk&utm_campaign=sign_up_complete_guide"
    help_work_link = "https://link.carepartner.kr/3QO0QRH"
    frequently_question_link = "https://link.carepartner.kr/3YBnG0E"

    {
      title: "[케어파트너] 가입 완료 안내",
      message: "환영합니다 선생님 :)
케어파트너 회원 가입이 완료되었어요.

선생님 댁 근처 요양일자리를 카카오톡 및 문자로 보내드릴게요.

≫ 한가지 더! 원하는 조건의 요양 일자리를 케어파트너에서 직접 찾아보고 지원하실 수도 있어요.

아래 버튼이나 링크를 눌러 궁금한 점을 지금 바로 해결해보세요👇",
      buttons: [
        {
          name: '3천 포인트 받으러 가기',
          type: 'WL',
          url_mobile: getting_point_link,
          url_pc: getting_point_link
        },
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

  def get_well_fitted_job(tem_params)
    link1 = "https://www.carepartner.kr/users/after_sign_up?utm_source=message&utm_medium=arlimtalk&utm_campaign=well-fitted-job"
    link2 = "https://pf.kakao.com/_xjwfcb/chat"

    {
      title: "[케어파트너] Draft 자격증 소지자 2일차",
      message: "#{tem_params[:name]} 선생님, 케어파트너에서 매일 매일 선생님께서 찾고계시던 일자리 정보를 보내드립니다.

지금 바로 케어파트너에 접속하여 축하 포인트도 받으시고, 원하는 조건에 맞는 맞춤 일자리 알림을 통해 더 나은 일자리에 취업을 성공해보세요.

아래 버튼을 눌러 주소 입력 방법에 대해 문의해 주시면 케어파트너 전문 상담사가 친절하게 알려드릴게요",
      buttons: [
        {
          name: '포인트&일자리 알림 받기',
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

  def get_certification_update(tem_params)
    link1 = "https://www.carepartner.kr/beginner/chatbot?utm_source=message&utm_medium=arlimtalk&utm_campaign=certification-update"

    {
      title: "[케어파트너] 미소지자 소지자 전환 알림톡",
      message: "#{tem_params[:name]} 선생님 케어파트너와 함께 준비하신 자격증 시험에 좋은 결과가 있으셨나요?

그동안 요양보호사 시험을 준비하시고 시험 보시느라 고생 많으셨어요. #{tem_params[:name]} 선생님의 새로운 도전을 항상 응원해요.

케어파트너에서는 요양보호사로 첫 발걸음을 내딛는 선생님께 도움드릴 수 있는 다양한 서비스를 제공하고 있어요.

1. 집 근처 초보 요양 일자리 추천
2. 급여 높은 요양 일자리 추천
3. 초보 요양보호사가 꼭 알아야 할 정보

아래 버튼을 누르시고 다양한 정보와 혜택 받아가세요.",
      buttons: [
        {
          name: '네, 합격했어요!',
          type: 'WL',
          url_mobile: link1,
          url_pc: link1
        }
      ]
    }
  end

  def get_post_comment(tem_params)
    host = Jets.env == 'production' ? 'carepartner' : 'dev-carepartner'
    title = "'#{tem_params[:post_title]}' 게시글"
    link = "https://www.#{host}.kr/community/question_answer/#{tem_params[:post_id]}?utm_source=message&utm_medium=arlimtalk&utm_campaign=post-comment"
    {
      title: "[케어파트너] 게시글 답변",
      message: "작성하신 #{title}에 답변이 달렸어요.

아래 버튼을 통해 답변을 확인해보세요.",
      buttons: [
        {
          name: '답변 보기',
          type: 'WL',
          url_mobile: link,
          url_pc: link
        }
      ]
    }
  end

  def get_call_interview_proposal_v2(tem_params)
    tel_link = tem_params[:tel_link]
    business_name = tem_params[:business_name]
    accept_link = tem_params[:accept_link]
    deny_link = tem_params[:deny_link]
    customer_info = tem_params[:customer_info]
    work_schedule = tem_params[:work_schedule]
    location_info = tem_params[:location_info]
    pay_info = tem_params[:pay_info]

    {
      title: "#{business_name}에서 전화면접을 제안했어요.",
      message: "#{business_name}에서 전화면접을 제안했어요.

■ 어르신 정보
#{customer_info}
■ 근무 시간
#{work_schedule}
■ 근무 장소
#{location_info}
■ 급여
#{pay_info}

✅ 공고가 조건에 맞다면?
아래 버튼을 눌러 제안을 수락하거나 문의해 보세요!

❌ 공고가 조건에 맞지 않다면?
거절 버튼을 눌러 기관에 의사를 전달해주세요!

(3일 내 응답하지 않으면 자동 거절됩니다)",
      buttons: [
        {
          type: 'WL',
          name: '✅ 제안 수락',
          url_mobile: accept_link,
          url_pc: accept_link
        },
        {
          type: 'WL',
          name: '❌ 제안 거절',
          url_mobile: deny_link,
          url_pc: deny_link

        },
        {
          type: 'AL',
          name: '📞 문의 전화하기',
          scheme_ios: tel_link,
          scheme_android: tel_link
        },
      ]
    }
  end

  def get_call_interview_proposal(tem_params)
    tel_link = tem_params[:tel_link]
    business_name = tem_params[:business_name]
    accept_link = tem_params[:accept_link]
    deny_link = tem_params[:deny_link]
    customer_info = tem_params[:customer_info]
    work_schedule = tem_params[:work_schedule]
    location_info = tem_params[:location_info]

    {
      title: "#{business_name}에서 전화면접을 제안했어요.",
      message: "#{business_name}에서 전화면접을 제안했어요.

■ 어르신 정보
#{customer_info}
■ 근무 시간
#{work_schedule}
■ 근무 장소
#{location_info}

✅ 공고가 조건에 맞다면?
아래 버튼을 눌러 제안을 수락하거나 문의해 보세요!

❌ 공고가 조건에 맞지 않다면?
거절 버튼을 눌러 기관에 의사를 전달해주세요!

(3일 내 응답하지 않으면 자동 거절됩니다)",
      buttons: [
        {
          type: 'AL',
          name: '✅ 제안 수락',
          url_mobile: accept_link,
          url_pc: accept_link
        },
        {
          type: 'WL',
          name: '❌ 제안 거절',
          url_mobile: deny_link,
          url_pc: deny_link

        },
        {
          type: 'WL',
          name: '📞 문의 전화하기',
          scheme_ios: tel_link,
          scheme_android: tel_link
        },
      ]
    }
  end

  def get_call_interview_proposal(tem_params)
    tel_link = tem_params[:tel_link]
    business_name = tem_params[:business_name]
    accept_link = tem_params[:accept_link]
    deny_link = tem_params[:deny_link]
    customer_info = tem_params[:customer_info]
    work_schedule = tem_params[:work_schedule]
    location_info = tem_params[:location_info]

    {
      title: "#{business_name}에서 전화면접을 제안했어요.",
      message: "#{business_name}에서 전화면접을 제안했어요.

■ 어르신 정보
#{customer_info}
■ 근무 시간
#{work_schedule}
■ 근무 장소
#{location_info}

✅ 공고가 조건에 맞다면?
아래 버튼을 눌러 제안을 수락하거나 문의해 보세요!

❌ 공고가 조건에 맞지 않다면?
거절 버튼을 눌러 기관에 의사를 전달해주세요!

(3일 내 응답하지 않으면 자동 거절됩니다)",
      buttons: [
        {
          type: 'AL',
          name: '📞 제안 수락 (전화)',
          scheme_ios: tel_link,
          scheme_android: tel_link
        },
        {
          type: 'WL',
          name: '💬 제안 수락 (메세지)',
          url_mobile: accept_link,
          url_pc: accept_link
        },
        {
          type: 'WL',
          name: '❌ 제안 거절',
          url_mobile: deny_link,
          url_pc: deny_link
        },
      ]
    }
  end

  def get_call_interview_accepted(tem_params)
    tel_link = tem_params[:tel_link]
    job_posting_title = tem_params[:job_posting_title]
    user_name = tem_params[:user_name]
    user_info = tem_params[:user_info]
    accepted_at = tem_params[:accepted_at]
    address = tem_params[:address]

    data = {
      title: "#{user_name} 요양보호사가 전화면접 제안을 수락했어요!",
      message: "#{user_name} 요양보호사가 전화면접 제안을 수락했어요!

공고 : #{job_posting_title}

■ 기본 정보 : #{user_info}
■ 수락 날짜 : #{DateTime.parse(accepted_at).strftime("%Y-%m-%d")}
■ 거주 주소 : #{address}

아래 전화하기 버튼을 눌러 전화면접을 진행해보세요!

(3일 내 응답하지 않으면 더 이상 전화할 수 없어요)",
      buttons: [
        {
          type: 'AL',
          name: '전화하기',
          scheme_ios: tel_link,
          scheme_android: tel_link
        }
      ]
    }
    data
  end

  def get_proposal_accept_data(tem_params)
    link = tem_params[:link]
    close_link = tem_params[:close_link]
    job_posting_title = tem_params[:job_posting_title]
    user_info = tem_params[:user_info]
    {
      title: "#{user_info} 요양보호사가 전화면접 제안을 수락했어요!",
      message: "#{user_info} 요양보호사가 전화면접 제안을 수락했어요.

■ 제안 수락한 공고
#{job_posting_title}

■ 도움말
제안 수락한 요양보호사는 채용 확률이 높아요. 아래 버튼을 눌러 확인후 요양보호사에게 무료로 전화해 보세요.",
      buttons: [
        {
          type: 'WL',
          name: '자세히 확인하기',
          url_mobile: link,
          url_pc: link
        },
        {
          type: 'WL',
          name: '알림 그만받기 (채용종료)',
          url_mobile: close_link,
          url_pc: close_link,
        }
      ]
    }
  end

  def get_call_saved_job_caregiver(tem_params)
    host = if Jets.env == 'production'
             'https://business.carepartner.kr'
           else
             'https://staging-business.vercel.app'
           end
    url_path = "#{tem_params[:url_path]}&utm_source=message&utm_medium=arlimtalk&utm_campaign=call_saved_job_caregiver"
    shorturl = ShortUrl.build(host + url_path, host)
    utm = "?utm_source=message&utm_medium=arlimtalk&utm_campaign=call_saved_care(close_avail)"
    close_link = "#{host}/recruitment_management/#{tem_params[:job_posting_public_id]}/close#{utm}"
    job_posting_title = tem_params[:job_posting_title]
    user_name = tem_params[:user_name]
    user_info = "#{user_name} / #{tem_params[:user_gender]} / #{tem_params[:user_age]}세"
    career = tem_params[:user_career]
    distance = tem_params[:user_distance]
    address = tem_params[:user_address]

    data = {
      title: "요양보호사 관심 표시",
      message: "#{user_name} 요양보호사가 아래 공고에 관심을 표시했어요!

공고 : #{job_posting_title}

■ 기본 정보 : #{user_info}
■ 근무 경력 : #{career}
■ 통근 거리 : #{distance}
■ 거주 주소 : #{address}

아래 전화하기 버튼을 눌러 공고에 관심표시한 요양보호사에게 지금 바로 전화해보세요!",
      buttons: [
        {
          type: 'WL',
          name: '자세히 확인하기',
          url_mobile: shorturl.url,
          url_pc: shorturl.url
        },
        {
          type: 'WL',
          name: '알림 그만받기 (채용종료)',
          url_mobile: close_link,
          url_pc: close_link
        }
      ]
    }

    data
  end

  def get_call_saved_job_posting_v2(tem_params)
    customer_info = tem_params[:customer_info]
    work_schedule = tem_params[:work_schedule]
    location_info = tem_params[:location_info]
    pay_text = tem_params[:pay_text]
    job_posting_public_id = tem_params[:job_posting_public_id]

    host = if Jets.env == 'production'
             'https://carepartner.kr'
           else
             'https://dev-carepartner.kr'
           end
    url = host + "/jobs/#{job_posting_public_id}?&utm_source=message&utm_medium=arlimtalk&utm_campaign=call_saved_job_posting"

    {
      title: "요양보호사 관심 표시",
      message: "관심을 표시한 공고에 전화해보세요!

■ 어르신 정보
#{customer_info}
■ 근무 요일
#{work_schedule}
■ 근무 장소
#{location_info}
■ 급여 정보
#{pay_text}

자세히 확인하기 버튼을 눌러 공고 담당자와 전화해보세요!",
      buttons: [
        {
          type: 'WL',
          name: '자세히 확인하기',
          url_mobile: url,
          url_pc: url }
      ]
    }
  end

  def get_ask_active(tem_params)
    {
      title: '아직 일자리를 찾고 있나요?',
      message: "#{tem_params[:user_name]} 요양보호사님, 현재 요양일자리를 찾고 있나요?

최근 선생님과 전화한 #{tem_params[:business_name]} 담당자가 #{tem_params[:user_name]} 선생님이 현재 일자리를 찾고 계시지 않다고 응답해 주셨어요.

일자리를 찾고 있지 않다면, 아래 버튼을 눌러주세요.

내주변 요양기관으로부터 취업 제안 전화 또는 문자를 그만받을 수 있어요.",
      buttons: [
        {
          type: 'WL',
          name: '취업 제안 그만받기',
          url_mobile: tem_params[:url],
          url_pc: tem_params[:url]
        }
      ]
    }
  end

  def get_new_job_visit_v2(tem_params)
    business_vn = convert_safe_text(tem_params[:business_vn])
    {
      title: tem_params[:title],
      message: "[케어파트너] 신규일자리 알림
전화: ☎#{tem_params[:business_vn]}

≫ 근무시간: #{tem_params[:days_text]} #{tem_params[:hours_text]}
≫ 근무지: #{tem_params[:address]} (#{tem_params[:distance]})
≫ 급여: #{tem_params[:pay_text]}
≫ 어르신 정보: #{tem_params[:customer_grade]}/#{tem_params[:customer_age]}세/#{tem_params[:customer_gender]}

아래 버튼 또는 링크를 클릭해서 자세한 내용 확인하고 지원해보세요!
carepartner.kr#{tem_params[:path]}

전화: ☎#{business_vn}",
      buttons: [
        {
          type: 'WL',
          name: '일자리 확인하기',
          url_mobile: tem_params[:origin_url],
          url_pc: tem_params[:origin_url]
        },
        {
          type: 'AL',
          name: '전화하기',
          scheme_ios: "tel://#{business_vn}",
          scheme_android: "tel://#{business_vn}"
        },
        {
          type: 'WL',
          name: '그만 받을래요',
          url_mobile: tem_params[:mute_url],
          url_pc: tem_params[:mute_url]
        }
      ]
    }

  end

  def get_new_job_facility_v2(tem_params)
    daysAndHours = "≫ 근무시간: #{convert_safe_text(tem_params[:days_text])} #{convert_safe_text(tem_params[:hours_text])}"
    address = "≫ 근무지: #{convert_safe_text(tem_params[:address])}"
    pay = "≫ 급여: #{convert_safe_text(tem_params[:pay_text])}"
    customer_info = "≫ 어르신 정보: #{convert_safe_text(tem_params[:customer_grade])}/#{convert_safe_text(tem_params[:customer_age])}세/#{convert_safe_text(tem_params[:customer_gender])}"
    business_vn = convert_safe_text(tem_params[:business_vn])
    postfix_url = tem_params[:postfix_url]
    origin_url = tem_params[:origin_url]
    mute_url = tem_params[:mute_url]
    path = tem_params[:path]

    return {
      title: tem_params[:title],
      message: "[케어파트너] 신규일자리 알림
전화: ☎#{business_vn}\n#{daysAndHours}\n#{address}\n#{pay}\n#{customer_info}

아래 버튼 또는 링크를 클릭해서 자세한 내용 확인하고 지원해보세요!

carepartner.kr#{path}

전화: ☎#{business_vn}",
      buttons: [
        {
          name: "일자리 확인하기",
          type: "WL",
          url_mobile: origin_url,
          url_pc: origin_url,
        },
        {
          name: "전화하기",
          type: "AL",
          scheme_ios: "tel://#{business_vn}",
          scheme_android: "tel://#{business_vn}",
        },
        {
          name: "그만 받을래요",
          type: "WL",
          url_mobile: mute_url,
          url_pc: mute_url
        }
      ]
    }
  end

  def get_new_job_posting(tem_params)
    alarm_setting_url = "https://www.carepartner.kr/me?utm_source=message&utm_medium=arlimtalk&utm_campaign=new_job_posting"

    {
      title: tem_params[:title],
      message: tem_params[:message],
      buttons: [
        {
          name: '🔎 일자리 확인하기',
          type: 'WL',
          url_pc: tem_params[:origin_url],
          url_mobile: tem_params[:origin_url]
        },
        {
          name: '❌ 그만 받을래요',
          type: 'WL',
          url_pc: tem_params[:mute_url],
          url_mobile: tem_params[:mute_url]
        },
        {
          name: '🔔 알림 지역 설정',
          type: 'WL',
          url_pc: alarm_setting_url,
          url_mobile: alarm_setting_url
        }
      ]
    }
  end

  def get_newspaper_v2(tem_params)
    today = NewsPaper.get_today
    url = tem_params[:link]
    mute_url = "https://www.carepartner.kr/me/notification/off?type=job&utm_source=message&utm_medium=arlimtalk&utm_campaign=newspaper_job_alarm"
    {
      title: '아직 일자리를 찾고 있나요?',
      message: "#{today} 일자리 신문이 도착했어요.

케어파트너 일자리 신문과 함께 하루를 시작해보세요.

👇'신문 확인하기' 버튼 클릭👇",
      buttons: [
        {
          type: 'WL',
          name: '신문 확인하기',
          url_mobile: url,
          url_pc: url
        },
        {
          type: 'WL',
          name: '그만 받을래요',
          url_mobile: mute_url,
          url_pc: mute_url,
        }
      ]
    }
  end

  def get_cbt_draft(tem_params)
    cbt_url = "https://cbt.carepartner.kr/delivery?utm_source=message&utm_medium=arlimtalk&utm_campaign=CBT-draft"
    counselor_url = "https://pf.kakao.com/_xjwfcb"
    {
      title: "실전 모의고사 풀고 요양보호사 자격증 시험 합격하세요!",
      message: "#{tem_params[:name]} 선생님 요양보호사 자격증 시험 준비중이신가요?
자격증 시험 합격을 위해 매일 실전 모의고사를 풀어보세요.
하루에 딱 5분으로 요양보호사 자격증 시험 준비를 도와드리겠습니다.
지금 등록하시면 최대 10회분의 모의고사도 무료로 제공해드려요!
아래 ’실전 모의고사 풀기’ 버튼을 눌러 오늘의 추천 문제를 풀어보시고 자격증 시험에 합격하세요!",
      buttons: [
        {
          type: 'WL',
          name: '실전 모의고사 풀기',
          url_mobile: cbt_url,
          url_pc: cbt_url
        },
        {
          type: 'WL',
          name: '케어파트너 문의하기',
          url_mobile: counselor_url,
          url_pc: counselor_url
        },
      ]
    }
  end

  def get_carepartner_draft(tem_params)
    alarm_setting_url = "https://www.carepartner.kr/users/after_sign_up?utm_source=message&utm_medium=arlimtalk&utm_campaign=carepartner_present"
    counselor_url = "https://pf.kakao.com/_xjwfcb"

    {
      title: "요양보호사 등록하면 혜택이 쏟아져요!",
      message: "#{tem_params[:name]} 선생님 요양보호사 자격증 갖고 계신가요?

케어파트너에 회원가입 해주셔서 감사합니다.

회원가입 후 추가로 자격증 여부를 알려주시면 감사 포인트와 선생님께서 찾고 계시는 일자리의 알림을 무료로 받아보실 수 있습니다.

<추가 정보 등록 시 혜택>
1. 높은 월급 일자리 추천
2. 선생님 맞춤 일자리 알림 평생 무료
3. 요양보호사 필수 정보 모음
4. 케어파트너에서 사용 가능한 감사 포인트

혹시 케어파트너를 이용하는 방법이 어려우셨다면, 걱정하지 마세요.

아래 버튼을 눌러 이용이 어려운 부분에 대해 문의 해주시면 케어파트너 전문 상담사가 친절하게 알려드릴게요.",
      buttons: [
        {
          type: 'WL',
          name: '일자리 무료 알림 신청',
          url_mobile: alarm_setting_url,
          url_pc: alarm_setting_url
        },
        {
          type: 'WL',
          name: '케어파트너 문의하기',
          url_mobile: counselor_url,
          url_pc: counselor_url
        },
      ]
    }
  end

  def get_accumulated_draft(tem_params)
    job_recommending_url = "https://www.carepartner.kr/users/after_sign_up?utm_source=message&utm_medium=arlimtalk&utm_campaign=accumulated_draft"
    counselor_url = "https://pf.kakao.com/_xjwfcb"

    {
      title: "요양보호사 등록하면 혜택이 쏟아져요!",
      message: "#{tem_params[:name]} 선생님 급여 높은 일자리를 찾고 계신가요?

전국 최대 규모 요양 일자리 서비스 케어파트너에서는 급여 높은 일자리를 매주 추천해드려요.

지금 바로 케어파트너에 접속하여 축하 포인트도 받으시고 원하는 일자리도 찾아보세요.

혹시 케어파트너를 이용하는 방법이 어려우셨다면, 걱정하지 마세요.

아래 버튼을 눌러 이용이 어려운 부분에 대해 문의 해주시면 케어파트너 전문 상담사가 친절하게 알려드릴게요.",
      buttons: [
        {
          type: 'WL',
          name: '급여 높은 일자리 추천받기',
          url_mobile: job_recommending_url,
          url_pc: job_recommending_url
        },
        {
          type: 'WL',
          name: '케어파트너 문의하기',
          url_mobile: counselor_url,
          url_pc: counselor_url
        },
      ]
    }
  end

  def get_accumulated_preparative(tem_params)
    chat_bot_url = "https://www.carepartner.kr/beginner?utm_source=message&utm_medium=arlimtalk&utm_campaign=accumulated_preparative"

    {
      title: "요양보호사 시험에 합격하셨나요?",
      message: "#{tem_params[:name]} 선생님 케어파트너와 함께 준비했던 요양보호사 시험은 잘 마무리하셨나요?

요양보호사 시험을 준비하시고 시험 보시느라 고생 많으셨습니다.

합격 여부를 떠나 #{tem_params[:name]} 선생님의 새로운 도전을 항상 응원하고 있습니다.

케어파트너에서는 요양보호사로 첫 발걸음을 내딛는 선생님께 도움 드릴 수 있는 다양한 서비스와 정보를 제공하고 있어요.

1.집 근처 초보 요양 일자리 추천
2.급여 높은 요양 일자리 추천
3.초보 요양보호사가 꼭 알아야 할 정보

아래 버튼을 누르시고 다양한 정보와 혜택 받아가세요.",
      buttons: [
        {
          type: 'WL',
          name: '네 합격했어요',
          url_mobile: chat_bot_url,
          url_pc: chat_bot_url
        },
        {
          type: 'WL',
          name: '아직 합격 못했어요',
          url_mobile: chat_bot_url,
          url_pc: chat_bot_url
        },
      ]
    }
  end

  def get_connect_result_user_survey_A(tem_params)
    job_posting_title = tem_params[:job_posting_title]
    job_posting_address = tem_params[:job_posting_address]
    job_posting_schedule = tem_params[:job_posting_schedule]
    link = tem_params[:link]

    {
      title: "#{job_posting_title} 공고에 취업하셨나요?",
      message: "#{job_posting_title} 공고에 취업하셨나요?

■ 근무 장소
#{job_posting_address}

■ 근무 요일
#{job_posting_schedule}

■ 인증 혜택
취업을 인증하면 백화점상품권(5천원)을 드려요.",
      buttons: [
        {
          type: "WL",
          name: "취업 인증하고 선물 받기",
          url_mobile: link,
          url_pc: link,
        }
      ]
    }
  end

  def get_connect_result_user_survey_B(tem_params)
    job_posting_title = tem_params[:job_posting_title]
    job_posting_address = tem_params[:job_posting_address]
    job_posting_schedule = tem_params[:job_posting_schedule]
    link = tem_params[:link]

    {
      title: "#{job_posting_title} 공고에 취업하셨나요?",
      message: "#{job_posting_title} 공고에 취업하셨나요?

■ 근무 장소
#{job_posting_address}

■ 근무 요일
#{job_posting_schedule}

■ 인증 혜택
취업 인증하면 매달 급여일에 맞춰 내가 받은 금액이 맞는지 확인해 드려요.",
      buttons: [
        {
          type: "WL",
          name: "취업 인증후 혜택 받기",
          url_mobile: link,
          url_pc: link,
        }
      ]
    }
  end

  def get_job_application(tem_params)
    job_posting_title = tem_params[:job_posting_title]
    user_info = tem_params[:user_info]
    user_message = tem_params[:user_message]
    preferred_call_time = tem_params[:preferred_call_time]
    link = tem_params[:link]
    close_link = tem_params[:close_link]
    {
      title: "#{user_info} 요양보호사가 지원했어요.",
      message: "#{user_info} 요양보호사가 지원했어요.

■ 지원자의 한마디
“#{user_message}”

■ 공고
#{job_posting_title}

■ 통화 가능한 시간
#{preferred_call_time}

아래 버튼을 눌러 지원자의 자세한 정보를 확인하고 무료로 전화해 보세요!",
      buttons: [
        {
          type: "WL",
          name: "지원자 확인하기",
          url_mobile: link,
          url_pc: link,
        },
        {
          type: "WL",
          name: "지원 그만받기 (채용종료)",
          url_mobile: close_link,
          url_pc: close_link,
        }
      ]
    }
  end

  def get_notify_free_job_posting_close_one_day_ago(tem_params)
    {
      title: "무료 공고 종료 1일전 안내",
      message: "#{tem_params[:title]} 공고가 1일 후 자동 종료될 예정입니다.
아직 채용되지 않았다면 케어파트너 [번개채용] 공고를 통해 요양보호사님을 만나보세요!

[번개채용] 공고는
1. 공고를 무제한 연장하실 수 있습니다.
2. 요양보호사 프로필을 먼저 조회하고, 면접 제안을 할 수 있습니다.
3. 채용되지 않으면 무료!

👇공고 연장하러가기👇",
      buttons: [
        {
          type: "WL",
          name: "공고 연장하러 가기!",
          url_mobile: tem_params[:link],
          url_pc: tem_params[:link],
        }
      ]
    }
  end

  def get_notify_free_job_posting_close(tem_params)
    {
      title: "무료 공고 종료 안내",
      message: "#{tem_params[:title]} 공고가 자동 종료되었습니다.
케어파트너 무료공고를 통해 요양보호사 분과 잘 연결이 되셨을까요?
아직 채용되지 않았다면 케어파트너 [번개채용] 공고를 통해 요양보호사님을 만나보세요!

[번개채용] 공고는
1. 공고를 무제한 연장하실 수 있습니다.
2. 요양보호사 프로필을 먼저 조회하고, 면접 제안을 할 수 있습니다.
3. 채용되지 않으면 무료!

👇공고 연장하러가기👇",
      buttons: [
        {
          type: "WL",
          name: "공고 연장하러 가기!",
          url_mobile: tem_params[:link],
          url_pc: tem_params[:link],
        }
      ]
    }
  end

  def get_roulette_ticket_receive(tem_params)
    url = if Jets.env == 'production'
            "https://www.carepartner.kr/event/roulette?utm_source=message&utm_medium=arlimtalk&utm_campaign=roulette_invite_complete"
          else
            "https://dev-carepartner.vercel.app/event/roulette?utm_source=message&utm_medium=arlimtalk&utm_campaign=roulette_invite_complete"
          end

    {
      title: "행운 룰렛 이용권을 사용해보세요!",
      message: "#{tem_params[:name]} 요양보호사 선생님 안녕하세요.

최대 10만원 신세계상품권을 받으실 수 있는 행운 룰렛 이용권 3장이 지급되었습니다.

행운 룰렛 돌리시고 10만원의 주인공이 되어보세요!",
      buttons: [
        {
          type: 'WL',
          name: '룰렛 이용권 사용하기',
          url_mobile: url,
          url_pc: url
        }
      ]
    }
  end

  def get_proposal_data(tem_params)
    center_name = tem_params[:business_name]
    tel_link = tem_params[:tel_link]
    accept_link = tem_params[:accept_link]
    deny_link = tem_params[:deny_link]
    customer_info = tem_params[:customer_info]
    work_schedule = tem_params[:work_schedule]
    location_info = tem_params[:location_info]
    pay_info = tem_params[:pay_info]
    client_message = tem_params[:client_message]

    return {
      title: "#{center_name}에서 전화면접을 제안했어요.",
      message: "#{center_name}에서 전화면접을 제안했어요.

■ 어르신 정보
#{customer_info}

■ 근무 요일
#{work_schedule}

■ 근무 장소
#{location_info}

■ 급여 정보
#{pay_info}

■ 제안 메세지
#{client_message}

* 3일 내 응답하지 않으면 자동 거절돼요",
      buttons: [
        {
          name: "📞 제안수락 (전화)",
          type: "AL",
          scheme_ios: tel_link,
          scheme_android: tel_link,
        },
        {
          name: '💬 제안수락 (문자)',
          type: 'WL',
          url_mobile: accept_link,
          url_pc: accept_link
        },
        {
          name: '❌ 제안거절',
          type: 'WL',
          url_mobile: deny_link,
          url_pc: deny_link
        },
      ]
    }
  end
  def get_smart_memo_data(tem_params)
    {
      title: "중요 통화 내용 대신 메모해드려요",
      message: "아래 통화에서 놓치면 안되는 중요한 내용, AI가 대신 메모해 놨어요. 지금 바로 확인해 보세요!

■ 요양보호사
#{[tem_params[:user_name], tem_params[:user_age], tem_params[:user_gender]].reject(&:nil?).join('/')}

■ 통화 시간
#{tem_params[:indur_minute]}분 / #{tem_params[:connected_at_text]}

■ 스마트 자동메모 내용
통화후 할 일/ 요양보호사 주요 정보/ 통화 내용 요약",
      buttons: [
        {
          name: '스마트 자동메모 확인하기',
          type: 'WL',
          url_pc: tem_params[:link],
          url_mobile: tem_params[:link]
        }
      ]
    }
  end

  def get_target_job_posting_performance_data(tem_params)
    {
      title: "오늘의 동네 광고 성과 공유 드려요",
      message: "지금까지 #{tem_params[:address]}에 거주하고 있는 요양보호사 #{tem_params[:count][:total]}명이 광고를 받았으며, 그 중 #{tem_params[:count][:read]}명이 광고를 클릭 했어요.

■ 공고제목
#{tem_params[:title]}

■ 광고 성과
간편지원 #{tem_params[:count][:job_applications]}명/ 문자문의 #{tem_params[:count][:contact_messages]}명/ 전화문의 #{tem_params[:count][:calls]}명

■ 지원자를 늘려 보세요
광고를 받았지만 반응이 없는 요양보호사 #{tem_params[:count][:total] - tem_params[:count][:read]}명에게 전화면접 제안해 보세요.",
      buttons: [
        {
          name: '동네광고 성과 보기',
          type: 'WL',
          url_pc: tem_params[:link],
          url_mobile: tem_params[:link]
        }
      ]
    }
  end

  def get_target_job_posting_ad_data(tem_params)
    {
      title: "동네 광고로 지원을 늘려보세요",
      message: "동네광고를 사용하면 광고를 통한 지원자에게 바로 연락할 수 있어요

■ 공고제목
#{tem_params[:title]}

■ 예상 노출수
#{tem_params[:address]} 거주 요양보호사 #{tem_params[:count]}명

지금 바로 아래 버튼을 눌러 빠르게 지원 받아보세요!",
      buttons: [
        {
          name: '동네 광고하기',
          type: 'WL',
          url_pc: tem_params[:link],
          url_mobile: tem_params[:link]
        }
      ]
    }
  end

  def get_target_job_posting_ad_2_data(tem_params)
    {
      title: "동네 광고로 지원을 늘려보세요",
      message: "요양보호사 지원을
빠르게 더 받고 싶으신가요?

‘동네광고’로 [#{tem_params[:count]}명]의
구직 중인 요양보호사에게
카카오톡으로 광고 할 수 있어요

:검은색_중간_작은_정사각형:️공고 제목
- #{tem_params[:title]}

:검은색_중간_작은_정사각형:️예상 발송 대상
- ‘#{tem_params[:address]} 거주 요양보호사 #{tem_params[:count]}명

더 많은 요양보호사 지원
지금 빠르게 받고 싶으시다면?

아래 [동네 광고하기]를 눌러주세요.",
      buttons: [
        {
          name: '동네 광고하기',
          type: 'WL',
          url_mobile: tem_params[:link]
        }
      ]
    }
  end

  def get_target_job_posting_ad_apply_data(tem_params)
    others_count = tem_params[:count][:job_applications] + tem_params[:count][:contact_messages] + tem_params[:count][:user_saves] - 1
    {
      title: "누군가 동네광고로 지원 및 문의했어요!",
      message: "#{tem_params[:user_info]} 요양보호사가 동네광고를 보고 #{tem_params[:application_type]}했어요.

■ 공고제목
#{tem_params[:title]}

■ 광고성과
간편지원 #{tem_params[:count][:job_applications]}명/ 문자문의 #{tem_params[:count][:contact_messages]}명/ 관심표시 #{tem_params[:count][:user_saves]}명

지금바로 동네광고를 시작하여 #{tem_params[:user_name]} #{others_count > 0 ? "외 #{others_count}명의" : "요보사의"} 지원·문의에 응답해 보세요!",
      buttons: [
        {
          name: '지원 · 문의 확인하기',
          type: 'WL',
          url_pc: tem_params[:link],
          url_mobile: tem_params[:link]
        },
        {
          name: '지원 그만받기 (채용종료)',
          type: 'WL',
          url_pc: tem_params[:close_link],
          url_mobile: tem_params[:close_link]
        }
      ]
    }
  end

  def get_target_user_job_posting_v3(tem_params)
    {
      title: tem_params[:title],
      message: tem_params[:message],
      buttons: [
        {
          name: '🔎 일자리 확인하기',
          type: 'WL',
          url_pc: tem_params[:link],
          url_mobile: tem_params[:link]
        },
        {
          name: '그만 받을래요',
          type: 'WL',
          url_pc: tem_params[:mute_link],
          url_mobile: tem_params[:mute_link]
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

  def get_contact_message(tem_params)
    job_posting_title = tem_params[:job_posting_title]
    user_info = tem_params[:user_info]
    user_message = tem_params[:user_message]
    preferred_call_time = tem_params[:preferred_call_time]
    link = tem_params[:link]
    close_link = tem_params[:close_link]
    {
      title: "#{user_info} 요양보호사가 문의했어요.",
      message: "#{user_info} 요양보호사가 문의했어요.

■ 문의내용
“#{user_message}”

■ 공고
#{job_posting_title}

■ 통화 가능한 시간
#{preferred_call_time}

아래 버튼을 눌러 지원자의 자세한 정보를 확인하고 무료로 전화해 보세요!",
      buttons: [
        {
          type: "WL",
          name: "문자문의 확인하기",
          url_mobile: link,
          url_pc: link,
        },
        {
          type: "WL",
          name: "문의 그만받기 (채용종료)",
          url_mobile: close_link,
          url_pc: close_link,
        }
      ]
    }
  end

  def get_confirm_career_certification_message(tem_params)
    job_posting_title = tem_params[:job_posting_title]
    user_info = tem_params[:user_info]
    user_name = tem_params[:user_name]
    link = tem_params[:link]
    {
      title: "#{user_name} 요양보호사가 아래 공고에 채용인증을 요청했어요. 맞다면 채용 결과 입력 후 전화번호 열람권(3장)을 받아 보세요.",
      message: "#{user_name} 요양보호사가 아래 공고에 채용인증을 요청했어요. 맞다면 채용 결과 입력 후 전화번호 열람권(3장)을 받아 보세요.

■ 공고
#{job_posting_title}

■ 요양보호사
#{user_info}

■ 혜택안내
채용 결과를 입력하면 요양보호사에게 즉시 전화할 수 있는 전화번호 열람권(3장/ 4,500원 상당)을 드려요.",
      buttons: [
        {
          type: "WL",
          name: "채용결과 입력하기",
          url_mobile: link,
          url_pc: link,
        }
      ]
    }
  end

  def get_none_ltc_request(tem_params)
    service = tem_params[:service]
    date = tem_params[:date]
    link = tem_params[:link]
    {
      title: "케어파트너 돌봄 플러스 서비스 상담 신청이 접수 되었어요",
      message: "케어파트너 돌봄 플러스 서비스 상담 신청이 접수 되었어요

■ 신청 서비스
#{service}

■ 상담 접수 일정
#{date}

■ 문의 내용 확인 후 케어파트너 담당 매니저가 고객님께 유선으로 연락드릴 예정입니다.

■ 빠른 상담을 원하신다면 아래 상담원 연결 버튼을 클릭하여 카카오톡으로 문의남겨주세요",
      buttons: [
        {
          type: "WL",
          name: "⚡ 상담원 연결	",
          url_mobile: link,
          url_pc: link,
        }
      ]
    }
  end

  def get_job_support_agreement(tem_params)
    center_name = tem_params[:center_name]
    link = tem_params[:link]
    {
      title: "일자리지원사업 요보사 동의 요청",
      message: "#{center_name} 채용담당자가 동의를 요청했어요.

■ 요청내용
한국노인인력개발원의 취업알선형 사업 신청에 동의와 확인이 필요한 내용이에요.

아래 버튼을 눌러 요청 내용에 동의해 주세요.",
      buttons: [
        {
          type: "WL",
          name: "동의하기",
          url_mobile: link,
        }
      ]
    }
  end
end