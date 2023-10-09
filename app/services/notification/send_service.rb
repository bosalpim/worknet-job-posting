class Notification::SendService
  include NotificationRequestHelper
  def self.send_messages(template_id, request_sources)
    new.send_messages(template_id, request_sources)
  end

  def initialize
    @template_service = KakaoTemplateService.new(KakaoTemplate::CALL_SAVED_JOB_POSTING_V2, 'AI', nil, nil)
    @process_results = []
  end
  def send_messages(template_id, request_sources)
    # 배치 처리 옵션 추가
    request_sources.each do |request_source|
      message_request_param = request_source[:message_request_param]
      if message_request_param.nil?
        raise "대상 템플릿 : #{template_id}, 메세지 생성에 이용되는 param 값은 message_request_param 키의 value로 지정해주세요."
      end

      request_param = nil
      rsp = nil
      send_medium = request_source[:send_medium]

      case send_medium
      when NotificationServiceJob::BIZM_POST_PAY
        request_param = @template_service.get_final_request_params(request_source[:message_request_param], false, request_source[:phone])
        rsp = send_bizm_post_pay(request_param)
      else
        raise "메세지 발송매체(#{send_medium})가 추가되지 않았습니다."
      end

      amplitude_log(send_medium, template_id, rsp, message_request_param)
      @process_results.push({ send_medium: send_medium, response: rsp })
    end
    @process_results
  end

  private

  def amplitude_log(send_medium, template_id, rsp, message_request_param)
    case send_medium
    when NotificationServiceJob::BIZM_POST_PAY
      KakaoNotificationLoggingHelper.send_log_for_bizmsg(rsp, template_id, message_request_param)
    else
      raise "발송매체(#{send_medium}) amplitude 로깅 처리가 추가되지 않았습니다."
    end
  end
  def send_bizm_post_pay(request_param)
    request_post_pay(request_param)
  end
end