class Notification::Factory::NotificationFactoryClass
  include NotificationSaveResultHelper

  DEEP_LINK_SCEHEME = "carepartner://app"
  KAKAO_ARLIMTALK = "kakao_arlimtalk"
  APP_PUSH = "app_push"

  AppPush = Notification::Factory::SendMedium::AppPush
  BizmPostPayMessage = Notification::Factory::SendMedium::BizmPostPayMessage
  BizmPrePayMessage = Notification::Factory::SendMedium::BizmPrePayMessage
  def initialize(message_template_id)
    # 알림 발송 대상 배열
    @list = nil

    # 알림 매체별 알림 배열
    @app_push_list = []
    @bizm_post_pay_list = []
    @bizm_pre_pay_list = []

    # 알림 매체별 알림 전송 결과 배열
    @app_push_result = []
    @bizm_post_pay_result = []
    @bizm_pre_pay_result = []

    @message_template_id = message_template_id
    target_medium = MessageTemplate.find_by(name: message_template_id).nil? ? KAKAO_ARLIMTALK : MessageTemplate.find_by(name: message_template_id).target_medium
    @target_medium = target_medium
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
    Jets.logger.info "전체 발송 대상자 : #{@list.nil? ? 0 : @list.count} 명 발송처리 완료"
    # app push 결과 처리
    save_results_app_push(@app_push_result, @message_template_id)
    # post_pay 결과 처리
    save_results_bizm_post_pay(@bizm_post_pay_result, @message_template_id)
    # pre_pay 결과 처리
    save_results_bizm_pre_pay(@bizm_pre_pay_result, @message_template_id)
  end

  private
  def send_app_push
    return unless check_class_type(@app_push_list, AppPush) == true
    send_process(@app_push_list, @app_push_result)
  end

  def send_bizm_post_pay
    return unless check_class_type(@bizm_post_pay_list, BizmPostPayMessage) == true
    send_process(@bizm_post_pay_list, @bizm_post_pay_result)
  end

  def send_bizm_pre_pay
    return unless check_class_type(@bizm_pre_pay_list, BizmPrePayMessage) == true
    send_process(@bizm_pre_pay_list, @bizm_pre_pay_result)
  end

  def check_class_type(message_list, message_type)
    message = message_list.first
    return nil if message.nil?
    unless message.is_a?(message_type)
      raise ArgumentError, "#{message_type} 전송 타입에 맞는 올바른 배열에 넣으셔야합니다."
    end
    true
  end

  def send_process(message_list, result_list)
    Jets.logger.info "#{__method__} called by: #{caller[0][/`(.*)'/, 1]}"
    Jets.logger.info "target_notification_count: #{message_list.count}"
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