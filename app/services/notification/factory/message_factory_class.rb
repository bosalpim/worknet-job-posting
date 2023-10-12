class Notification::Factory::MessageFactoryClass
  include NotificationSaveResultHelper

  AppPush = Notification::Factory::SendMedium::AppPush
  BizmPostPayMessage = Notification::Factory::SendMedium::BizmPostPayMessage
  BizmPrePayMessage = Notification::Factory::SendMedium::BizmPrePayMessage
  def initialize(message_template_id)
    @app_push_list = []
    @bizm_post_pay_list = []
    @bizm_pre_pay_list = []

    @app_push_result = []
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
    # app push 결과 처리
    save_results_app_push(@app_push_result, @message_template_id)
    save_results_bizm_post_pay(@bizm_post_pay_result, @message_template_id)
    # pre_pay 결과 처리
  end

  private
  def send_app_push
    return unless check_send_medium_type(@app_push_list) == true
    send_process(@app_push_list, @app_push_result)
  end

  def send_bizm_post_pay
    return unless check_send_medium_type(@bizm_post_pay_list) == true
    send_process(@bizm_post_pay_list, @bizm_post_pay_result)
  end

  def send_bizm_pre_pay
    return unless check_send_medium_type(@bizm_pre_pay_list) == true
    send_process(@bizm_pre_pay_list, @bizm_pre_pay_result)
  end

  def check_send_medium_type(message_list)
    message = message_list.first
    return nil if message.nil?
    unless message.is_a?(Notification::Factory::SendMedium::Abstract)
      raise ArgumentError, "메세지 발송은 SendMedium Class를 상속받아 구현된 Class를 사용해야합니다."
    end
    true
  end

  def send_process(message_list, result_list)
    Jets.logger.info "#{__method__} called by: #{caller[0][/`(.*)'/, 1]}"
    message_list.each_slice(10) do |batch|
      threads = []

      batch.each do |message|
        threads << Thread.new do ||
          result = message.send_request
          result_list.push(result)
        end
      end

      threads.each(&:join)
    end
  end
end