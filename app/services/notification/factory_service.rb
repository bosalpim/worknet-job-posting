class Notification::FactoryService
  # @param template_id : 메세지 Template
  # @params params : 각 template에 사용되는 변수
  # @return [{ send_medium: "BizM" OR "AppPush", message_request_param: {}, message_}]
  def self.create(template_id, params)
    case template_id
    when MessageTemplate::CALL_SAVED_JOB_POSTING_V2
      return Notification::Factory::CallSavedJobPostingV2.new
    else
      return []
    end
  end
end