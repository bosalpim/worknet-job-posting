class Notification::CreateService


  # @param template_id : 메세지 Template
  # @params params : 각 template에 사용되는 변수
  # @return [{ send_medium: "BizM" OR "AppPush", message_request_param: {}, message_}]
  def self.create(template_id, params)
    case template_id
    when KakaoTemplate::CALL_SAVED_JOB_POSTING_V2
      return Notification::CreateMessage::CallSavedJobPostingV2.create
    else
      return []
    end
  end
end