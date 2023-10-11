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

  def notify
    send_app_push
    send_bizm_post_pay
    send_bizm_pre_pay
  end

  def save_result

  end

  private
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
    message = @bizm_pre_pay_list.first
    return if message.nil?
    unless message.is_a?(BizmPrePayMessage)
      raise ArgumentError, "@bizm_post_pay_list에는 BizmPrePayMessage Class만 주입하여 사용합니다."
    end

    @bizm_pre_pay_list.each do |bizm_message|
      result = bizm_message.send_request
      @bizm_pre_pay_result.push(result)
    end
  end
end