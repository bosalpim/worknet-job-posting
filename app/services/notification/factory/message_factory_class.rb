class Notification::Factory::MessageFactoryClass
  def initialize(message_template_id, message_type = 'AI')
    @push_list = []
    @bizm_post_pay_list = []
    @bizm_pre_pay_list = []

    @push_result = []
    @bizm_post_pay_result = []
    @bizm_pre_pay_result = []

    @message_template_id = message_template_id
  end

  def create_message
    raise NotImplementedError, "#{self.class}에서 해당 '#{__method__}'를 구현하지 않았습니다. Notification::CreateMessage::CallSavedJobPostingV2를 참고하여 개발해주세요."
  end
  def send_app_push
    push = @push_list.first
    return if push.nil?
    unless push.is_a?(AppPush)
      raise ArgumentError, "@push_list에는 AppPush Class만 주입하여 사용합니다."
    end

    @push_list.each do |app_push|
      result = app_push.send_request
      @push_result.push(result)
    end
  end

  def send_bizm_post_pay
    message = @bizm_post_pay_list.first
    return if message.nil?
    unless message.is_a?(BizmPostPayMessage)
      raise ArgumentError, "@bizm_post_pay_list에는 BizmPostPayMessage Class만 주입하여 사용합니다."
    end

    @bizm_post_pay_list.each do |bizm_message|
      bizm_message.send_request
    end
  end

  def send_bizm_pre_pay
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
class AppPush
  include NotificationRequestHelper
  # FCM
  def initialize(message_template_id, to, collapse_key, notification, target_public_id)
    @message_template_id = message_template_id
    @to = to
    @collapse_key = collapse_key
    @notification = notification
    @target_public_id = target_public_id
  end

  # FCM
  def send_request
    request_app_push({ to: @to, collapse_key: @collapse_key, notification: @notification }, @target_public_id)
  end

  def amplitude_log()

  end
end

class BizmPostPayMessage
  include NotificationRequestHelper
  def initialize(message_template_id, phone, params, target_public_id)
    @message_template_id = message_template_id
    @params = params
    @target_public_id = target_public_id
    @bizm_template_service = KakaoTemplateService.new(message_template_id, message_type, phone, nil)
  end

  def send_request
    request_params = @bizm_template_service.get_final_request_params(@params, false)
    request_post_pay(request_params, @target_public_id)
  end

  def amplitude_log()

  end
end

class BizmPrePayMessage
  include NotificationRequestHelper
  def initialize(message_template_id, phone, params, target_public_id)
    @message_template_id = message_template_id
    @params = params
    @target_public_id = target_public_id
    @bizm_template_service = KakaoTemplateService.new(message_template_id, message_type, phone, nil)
  end

  def send_request
    request_params = @bizm_template_service.get_final_request_params(@params, true)
    request_pre_pay(request_params)
  end

  def amplitude_log()

  end
end