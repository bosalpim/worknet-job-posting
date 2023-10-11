class Notification::Factory::MessageFactoryClass
  AppPush = Notification::Factory::SendMedium::AppPush
  BizmPostPayMessage = Notification::Factory::SendMedium::BizmPostPayMessage
  BizmPrePayMessage = Notification::Factory::SendMedium::BizmPrePayMessage
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
      result = bizm_message.send_request
      @bizm_post_pay_result.push(result)
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
    begin
      response = request_app_push({ to: @to, collapse_key: @collapse_key, notification: @notification })
      success = response["success"]
      if success == 1
        return { status: 'success', response: response, target_public_id: @target_public_id }
      else
        return { status: 'fail', response: response.to_s, target_public_id: @target_public_id }
      end
    rescue Net::ReadTimeout
      return { status: 'fail', response: "NET::TIMEOUT", target_public_id: @target_public_id }
    rescue HTTParty::Error => e
      return { status: 'fail', response: "#{e.message}", target_public_id: @target_public_id }
    end
  end
end

class BizmPostPayMessage
  include NotificationRequestHelper
  def initialize(message_template_id, message_type = "AT", phone, params, target_public_id)
    @message_template_id = message_template_id
    params[:target_public_id] = target_public_id
    @params = params
    @target_public_id = target_public_id
    @bizm_template_service = KakaoTemplateService.new(message_template_id, message_type, phone, nil)
  end

  def send_request
    request_params = @bizm_template_service.get_final_request_params(@params, false)
    begin
      response = request_post_pay(request_params)
      response.class == Array ? response.first : response
      amplitude_log(response)
      { status: 'success', response: response, target_public_id: @target_public_id }
    rescue Net::ReadTimeout
      { status: 'fail', response: "NET::TIMEOUT", target_public_id: @target_public_id }
    rescue HTTParty::Error => e
      { status: 'fail', response: "#{e.message}", target_public_id: @target_public_id }
    end
  end

  def amplitude_log(response)
    KakaoNotificationLoggingHelper.send_log_for_bizmsg(response, @message_template_id, @params)
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
    begin
      response = request_pre_pay(request_params)
      response.class == Array ? response.first : response
      amplitude_log(response)
      { status: 'success', response: response, target_public_id: @target_public_id }
    rescue Net::ReadTimeout
      { status: 'fail', response: "NET::TIMEOUT", target_public_id: @target_public_id }
    rescue HTTParty::Error => e
      { status: 'fail', response: "#{e.message}", target_public_id: @target_public_id }
    end
  end

  def amplitude_log(response)
    KakaoNotificationLoggingHelper.send_log(response, @message_template_id, @params)
  end
end