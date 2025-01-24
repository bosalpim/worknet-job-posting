module KakaoNotificationLoggingHelper
  include MessageTemplateName
  include AlimtalkMessage

  NOTIFICATION_EVENT_NAME = '[Action] Receive Notification'
  NOTIFICATION_EVENT_NAME2 = '[Action] Receive Notification2'

  SENDER_TYPE_CAREPARTNER = 'carepartner'
  SENDER_TYPE_BUSINESS = 'business'
  SENDER_TYPE_USER = 'user'

  RECEIVER_TYPE_BUSINESS = 'business'
  RECEIVER_TYPE_USER = 'user'

  NOTIFICATION_TYPE_KAKAO = 'kakao_notification'
  NOTIFICATION_TYPE_RESERVED = 'kakao_notification_reserved'
  NOTIFICATION_TYPE_APP_PUSH = 'app_push'
  NOTIFICATION_TYPE_TEXT_MESSAGE = 'text_message'

  def self.get_logging_data2(template_id, tem_params)
    target_public_id = tem_params.dig(:target_public_id)
    target_public_id = tem_params.dig("target_public_id") if target_public_id.nil?

    if target_public_id.nil?
      return nil
    end

    return {
      "user_id" => target_public_id,
      "event_type" => NOTIFICATION_EVENT_NAME2,
      "event_properties" => {
        "template" => template_id,
        "template_params" => tem_params
      }
    }
  end

  def self.get_logging_data(template_id, tem_params)
    target_public_id = tem_params.dig(:target_public_id)
    target_public_id = tem_params.dig("target_public_id") if target_public_id.nil?

    if target_public_id.nil?
      return nil
    end

    case template_id
    when MessageTemplateName::NEWSPAPER_V2
      return get_news_paper_logging_data(template_id, target_public_id, tem_params)
    when MessageTemplateName::NEWSPAPER_V3
      return get_news_paper_v3_logging_data(template_id, target_public_id, tem_params)
    when MessageTemplates[MessageNames::CLOSE_JOB_POSTING_NOTIFICATION]
      return get_close_job_posting_notification_logging_data(tem_params, template_id, target_public_id)
    when MessageTemplateName::CANDIDATE_RECOMMENDATION
      return get_candidate_recommendation_logging_data(template_id, tem_params)
    when MessageTemplateName::USER_CALL_REMINDER
      # 기관이 요보사한테 전화했는데 부재중일 경우
      return get_user_call_reminder_logging_data(template_id, tem_params)
    when MessageTemplateName::MISSED_CAREGIVER_TO_BUSINESS_CALL
      # 요보사가 기관한테 전화했는데 부재중일 경우
      return get_missed_caregiver_to_business_call_logging_data(template_id, tem_params)
    when MessageTemplateName::BUSINESS_CALL_APPLY_USER_REMINDER
      # 기관에게 전화신청한 요보사가 기관의 전화를 안 받았을 경우
      return get_business_call_apply_user_reminder(template_id, tem_params)
    when MessageTemplateName::CALL_REQUEST_ALARM
      # 요보사가 기관한테 전화신청했을 경우
      return get_call_request_alarm_logging_data(template_id, tem_params)
    when MessageTemplateName::PROPOSAL_RESPONSE_EDIT
      # 기관이 요보사에게 일자리 제안을 보냈을 경우
      return get_proposal_response_edit_logging_data(template_id, tem_params)
    when MessageTemplateName::PROPOSAL_ACCEPTED
      # 요보사가 일자리 제안을 수락했을 경우
      return get_proposal_accepted_logging_data(template_id, tem_params)
    when MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_DRAFT_CRM]
      return get_draft_conversion_msg_logging_data(template_id, tem_params)
    when MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_DRAFT_CRM]
      return get_draft_conversion_msg_logging_data(template_id, tem_params)
    when MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_ADDRESS_LEAK_CRM]
      return get_draft_conversion_msg_logging_data(template_id, tem_params)
    when MessageTemplateName::CERTIFICATION_UPDATE
      return get_draft_conversion_msg_logging_data(template_id, tem_params)
    when MessageTemplateName::SIGNUP_COMPLETE_GUIDE
      return get_draft_conversion_msg_logging_data(template_id, tem_params)
    when MessageTemplateName::SIGNUP_COMPLETE_GUIDE3
      return get_draft_conversion_msg_logging_data(template_id, tem_params)
    when MessageTemplateName::CALL_INTERVIEW_PROPOSAL, CALL_INTERVIEW_PROPOSAL_V2
      return get_call_interview_proposal_logging_data(template_id, tem_params)
    when PROPOSAL
      return get_proposal_logging_data(template_id, tem_params)
    when PROPOSAL_ACCEPT
      return get_proposal_accept_logging_data(template_id, tem_params)
    when MessageTemplateName::CALL_SAVED_JOB_CAREGIVER
      return get_call_saved_job_caregiver(template_id, tem_params)
    when MessageTemplateName::CALL_SAVED_JOB_POSTING_V2
      return get_call_saved_job_caregiver2(template_id, tem_params)
    when MessageTemplateName::ASK_ACTIVE
      return get_ask_active_logging_data(template_id, tem_params)
    when MessageTemplates[MessageNames::CBT_DRAFT_CRM]
      return get_cbt_logging_data(template_id, tem_params)
    when MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM]
      return carepartner_null_certification_logging_data(template_id, tem_params)
    when MessageTemplateName::ACCUMULATED_DRAFT
      return get_accumulate_draft_logging_data(template_id, tem_params)
    when MessageTemplateName::ACCUMULATED_PREPARATIVE
      return get_accumulate_preparative_cbt_logging_data(template_id, tem_params)
    when CONNECT_RESULT_USER_SURVEY_A, CONNECT_RESULT_USER_SURVEY_B
      return get_connect_result_user_survey(template_id, tem_params)
    when MessageTemplateName::ROULETTE
      return get_draft_conversion_msg_logging_data(template_id, tem_params)
    when JOB_APPLICATION
      return get_job_application(template_id, tem_params)
    when MessageTemplateName::CLOSE_JOB_POSTING_REMIND_1DAY_AGO
      return get_notify_free_job_posting_close(template_id, tem_params, target_public_id)
    when CAREER_CERTIFICATION_V2
      return get_career_certification_v2(template_id, tem_params)
    when CONTACT_MESSAGE
      return get_contact_message(template_id, tem_params)
    when MessageTemplateName::CONFIRM_CAREER_CERTIFICATION
      return get_confirm_career_certification(tem_params, template_id)
    when MessageTemplateName::BUSINESS_JOB_POSTING_COMPLETE
      return get_business_base_event(tem_params, template_id)
    when MessageTemplateName::SMART_MEMO
      return get_smart_memo_logging_data(tem_params)
    when MessageTemplateName::TARGET_USER_JOB_POSTING
      return get_target_message_logging_data(template_id, tem_params)
    when MessageTemplateName::TARGET_USER_JOB_POSTING_V2
      return get_target_message_logging_data(template_id, tem_params)
    when MessageTemplateName::TARGET_JOB_POSTING_PERFORMANCE
      return get_target_job_posting_performance_logging_data(template_id, tem_params)
    when MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY
      return get_target_job_posting_ad_apply_logging_data(template_id, tem_params)
    when MessageTemplateName::JOB_SUPPORT_REQUEST_AGREEMENT
      return get_job_support_request_logging_data(template_id, tem_params)
    when MessageTemplateName::TARGET_USER_RESIDENT_POSTING
      return get_target_resident_posting_message_logging_data(template_id, tem_params)
    when MessageTemplateName::PROPOSAL_RESIDENT
      return get_proposal_resident_logging_data(template_id, tem_params)
    when MessageTemplateName::CAREER_CERTIFICATION_V3
      return get_employment_confirmation_logging_data(template_id, tem_params)
    when MessageTemplates[MessageNames::TARGET_USER_JOB_POSTING]
      return get_target_user_job_posting_logging_data(template_id, tem_params)
    when MessageTemplates[MessageNames::TARGET_JOB_BUSINESS_FREE_TRIALS]
      return get_target_business_free_trials(template_id, tem_params)
    else
      puts "WARNING: Amplitude Logging Missing else case!"
    end
  end

  def self.get_business_base_event(tem_params, template_id)
    target_public_id = tem_params.dig(:target_public_id)
    job_posting_public_id = tem_params.dig(:job_posting_public_id)
    title = tem_params.dig(:job_posting_title)

    return {
      "user_id" => target_public_id,
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_BUSINESS,
        "jobPostingId" => job_posting_public_id,
        "title" => title,
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end

  def self.get_notify_free_job_posting_close(template_id, tem_params, target_public_id)
    job_posting_public_id = tem_params.dig(:job_posting_public_id)
    title = tem_params.dig(:title)

    return {
      "user_id" => target_public_id,
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_BUSINESS,
        "template" => template_id,
        "jobPostingId" => job_posting_public_id,
        "title" => title,
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end

  def self.get_close_job_posting_notification_logging_data(template_params, template_id, target_public_id)
    job_posting_public_id = template_params.dig(:job_posting_public_id)
    title = template_params.dig(:title)

    return {
      "user_id" => target_public_id,
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_BUSINESS,
        "template" => template_id,
        "jobPostingId" => job_posting_public_id,
        "title" => title,
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end

  def self.get_news_paper_logging_data(template_id, target_public_id, tem_params)
    return {
      "user_id" => target_public_id,
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_USER,
        "template" => template_id,
        "send_at" => Time.current + (9 * 60 * 60),
      }
    }
  end

  def self.get_news_paper_v3_logging_data(template_id, target_public_id, tem_params)
    return {
      "user_id" => target_public_id,
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_USER,
        "template" => template_id,
        "send_at" => Time.current + (9 * 60 * 60),
      }
    }
  end

  def self.get_candidate_recommendation_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "centerName" => tem_params[:business_name],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "employee_id" => tem_params[:employee_id],
        "sender_type" => SENDER_TYPE_CAREPARTNER,
        "receiver_type" => RECEIVER_TYPE_BUSINESS,
        "template" => template_id,
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end

  def self.get_user_call_reminder_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
      }
    }
  end

  def self.get_missed_caregiver_to_business_call_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "centerName" => tem_params[:business_name],
      }
    }
  end

  def self.get_business_call_apply_user_reminder(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "employee_id" => tem_params[:employee_id],
        "centerName" => tem_params[:business_name]
      }
    }
  end

  def self.get_call_request_alarm_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "employee_id" => tem_params[:employee_id],
        "centerName" => tem_params[:business_name]
      }
    }
  end

  def self.get_proposal_response_edit_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "centerName" => tem_params[:business_name]
      }
    }
  end

  def self.get_proposal_accepted_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "employee_id" => tem_params[:employee_id],
        "centerName" => tem_params[:business_name]
      }
    }
  end

  def self.get_draft_conversion_msg_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id
      }
    }
  end

  def self.get_call_interview_proposal_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "centerName" => tem_params[:business_name],
        "jobPostingId" => tem_params[:job_posting_id],
        "title" => tem_params[:job_posting_title],
      }
    }
  end

  def self.get_proposal_resident_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "centerName" => tem_params[:business_name],
        "jobPostingId" => tem_params[:job_posting_id],
        "jobPostingPublicId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
      }
    }
  end

  def self.get_employment_confirmation_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
      }
    }
  end

  def self.get_proposal_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "centerName" => tem_params[:business_name],
        "jobPostingId" => tem_params[:job_posting_id],
        "title" => tem_params[:job_posting_title],
        "message" => tem_params[:client_message],
        "highWage" => tem_params[:is_high_wage],
        "canNegotiateWorkTime" => tem_params[:is_can_negotiate_work_time],
        "transportationExpenses" => tem_params[:is_support_transportation_expences],
        "canApplyNewBie" => tem_params[:is_newbie_appliable]
      }
    }
  end

  def self.get_proposal_accept_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "centerName" => tem_params[:business_name],
        "jobPostingId" => tem_params[:job_posting_id],
        "title" => tem_params[:job_posting_title],
        "employee_id" => tem_params[:employee_id],
        "message" => tem_params[:client_message],
        "highWage" => tem_params[:is_high_wage],
        "canNegotiateWorkTime" => tem_params[:is_can_negotiate_work_time],
        "transportationExpenses" => tem_params[:is_support_transportation_expences],
        "canApplyNewBie" => tem_params[:is_newbie_appliable]
      }
    }
  end

  def self.get_call_saved_job_caregiver(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "centerName" => tem_params[:center_name],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "employee_id" => tem_params[:user_public_id],
        "type_match" => tem_params[:type_match],
        "gender_match" => tem_params[:gender_match],
        "day_match" => tem_params[:day_match],
        "time_match" => tem_params[:time_match],
        "grade_match" => tem_params[:grade_match]
      }
    }
  end

  def self.get_call_saved_job_caregiver2(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "centerName" => tem_params[:center_name],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "type_match" => tem_params[:type_match],
        "gender_match" => tem_params[:gender_match],
        "day_match" => tem_params[:day_match],
        "time_match" => tem_params[:time_match],
        "grade_match" => tem_params[:grade_match]
      }
    }
  end

  def self.get_ask_active_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "centerName" => tem_params[:business_name],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:title],
      }
    }
  end

  def self.get_cbt_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => "CBT Draft Message",
      }
    }
  end

  def self.carepartner_null_certification_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => "Carepartner Draft null Certification Message",
      }
    }
  end

  def self.get_accumulate_draft_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => "Accumulate Draft Message",
      }
    }
  end

  def self.get_accumulate_preparative_cbt_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => "Accumulate Preparative Cbt Message",
      }
    }
  end

  def self.get_connect_result_user_survey(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => tem_params[:job_posting_title],
        "jobPostingId" => tem_params[:job_posting_id],
        "centerName" => tem_params[:center_name],
        "type_match" => tem_params[:type_match],
        "gender_match" => tem_params[:gender_match],
        "day_match" => tem_params[:day_match],
        "time_match" => tem_params[:time_match],
        "grade_match" => tem_params[:grade_match],
      }
    }
  end

  def self.get_job_application(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => tem_params[:job_posting_title],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "employee_id" => tem_params[:user_public_id],
        "centerName" => tem_params[:business_name],
        "type_match" => tem_params[:type_match],
        "gender_match" => tem_params[:gender_match],
        "day_match" => tem_params[:day_match],
        "time_match" => tem_params[:time_match],
        "grade_match" => tem_params[:grade_match],
      }
    }
  end

  def self.get_career_certification_v2(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => tem_params[:job_posting_title],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "centerName" => tem_params[:center_name],
        "type_match" => tem_params[:type_match],
        "gender_match" => tem_params[:gender_match],
        "day_match" => tem_params[:day_match],
        "time_match" => tem_params[:time_match],
        "grade_match" => tem_params[:grade_match],
      }
    }
  end

  def self.send_log_for_bizmsg(response, template_id, template_params)
    logging_data = get_logging_data(template_id, template_params)
    return if logging_data.nil?

    result = response.dig("result")
    code = response.dig("code")

    if result == "Y"
      if code == "K000"
        logging_data["event_properties"]["type"] = NOTIFICATION_TYPE_KAKAO
      elsif code == "R000"
        logging_data["event_properties"]["type"] = NOTIFICATION_TYPE_RESERVED
      else
        logging_data["event_properties"]["type"] = NOTIFICATION_TYPE_TEXT_MESSAGE
      end

      AmplitudeService.instance.log_array([logging_data])
    else
      return
    end
  end

  def self.send_log(response, template_id, template_params)
    logging_data = get_logging_data(template_id, template_params)
    logging_data2 = get_logging_data2(template_id, template_params)

    return if logging_data.nil?
    return if logging_data2.nil?

    response_code = response.dig("code")
    response_message = response.dig("message")

    if response_code == "success"
      if response_message == "K000"
        logging_data["event_properties"]["type"] = NOTIFICATION_TYPE_KAKAO
        logging_data2["event_properties"]["type"] = NOTIFICATION_TYPE_KAKAO
      elsif response_message == "R000"
        logging_data["event_properties"]["type"] = NOTIFICATION_TYPE_RESERVED
        logging_data2["event_properties"]["type"] = NOTIFICATION_TYPE_RESERVED
      else
        logging_data["event_properties"]["type"] = NOTIFICATION_TYPE_TEXT_MESSAGE
        logging_data2["event_properties"]["type"] = NOTIFICATION_TYPE_TEXT_MESSAGE
      end

      AmplitudeService.instance.log_array([logging_data, logging_data2])
    else
      return
    end
  end

  def self.get_contact_message(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => tem_params[:job_posting_title],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "employee_id" => tem_params[:user_public_id],
        "centerName" => tem_params[:business_name],
        "type_match" => tem_params[:type_match],
        "gender_match" => tem_params[:gender_match],
        "day_match" => tem_params[:day_match],
        "time_match" => tem_params[:time_match],
        "grade_match" => tem_params[:grade_match],
      }
    }
  end

  def self.get_confirm_career_certification(tem_params, template_id)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => tem_params[:job_posting_title],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "employee_id" => tem_params[:user_public_id],
        "centerName" => tem_params[:business_name],
        "type_match" => tem_params[:type_match],
        "gender_match" => tem_params[:gender_match],
        "day_match" => tem_params[:day_match],
        "time_match" => tem_params[:time_match],
        "grade_match" => tem_params[:grade_match],
      }
    }
  end

  def self.get_smart_memo_logging_data(tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => SMART_MEMO,
        "employee_id" => tem_params[:user_public_id],
        "jobPostingId" => tem_params[:job_posting_public_id],
        "call_time" => tem_params[:indur],
        "call_type" => tem_params[:connected_type],
        "job_postings_connect_id" => tem_params[:job_postings_connect_id],
        "centerName" => tem_params[:business_name],
      }
    }
  end

  def self.get_target_resident_posting_message_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => tem_params[:is_free] ? 'free_user_resident_posting' : template_id,
        "jobPostingId" => tem_params[:job_posting_id],
        "jobPostingPublicId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "centerName" => tem_params[:business_name],
        "job_posting_type" => tem_params[:job_posting_type],
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end

  def self.get_target_message_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "jobPostingId" => tem_params[:job_posting_id],
        "job_posting_public_id" => tem_params[:job_posting_public_id],
        "title" => tem_params[:job_posting_title],
        "centerName" => tem_params[:business_name],
        "job_posting_type" => tem_params[:job_posting_type],
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end

  def self.get_target_job_posting_performance_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => "Target Message Performance",
        "job_posting_id" => tem_params[:job_posting_id],
        "center_name" => tem_params[:center_name],
        "target_num" => tem_params[:count][:total],
        "read_num" => tem_params[:count][:read],
        "apply_num" => tem_params[:count][:job_applications],
        "contact_num" => tem_params[:count][:contact_messages],
        "call_num" => tem_params[:count][:calls],
      }
    }
  end

  def self.get_target_job_posting_ad_apply_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "title" => "Target Message Ad Apply",
        "center_name" => tem_params[:center_name],
        "jobPostingId" => tem_params[:job_posting_id],
        "employee_id" => tem_params[:user_id],
      }
    }
  end

  def self.get_job_support_request_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "birth_year" => tem_params[:birth_year],
        "title" => tem_params[:title],
        "employee_id" => tem_params[:employee_id],
        "center_name" => tem_params[:center_name],
        "job_posting_id" => tem_params[:job_posting_id],
      }
    }
  end

  def self.get_target_user_job_posting_logging_data(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => tem_params[:is_free] ? 'free_user_job_posting' : template_id,
        "jobPostingId" => tem_params[:job_posting_id],
        "jobPostingPublicId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:title],
        "centerName" => tem_params[:business_name],
        "job_posting_type" => tem_params[:job_posting_type],
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end
  def self.get_target_business_free_trials(template_id, tem_params)
    return {
      "user_id" => tem_params[:target_public_id],
      "event_type" => NOTIFICATION_EVENT_NAME,
      "event_properties" => {
        "template" => template_id,
        "jobPostingId" => tem_params[:job_posting_id],
        "jobPostingPublicId" => tem_params[:job_posting_public_id],
        "title" => tem_params[:title],
        "centerName" => tem_params[:business_name],
        "job_posting_type" => tem_params[:job_posting_type],
        "send_at" => Time.current + (9 * 60 * 60)
      }
    }
  end

end