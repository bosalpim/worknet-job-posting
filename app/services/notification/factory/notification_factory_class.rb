class Notification::Factory::NotificationFactoryClass
  include NotificationSaveResultHelper

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

    # 구인 비서 공고 알림 일자리 발송 개별 관리
    # 개별 메세지 저장 table dispatched_notifications를 활용할 때, 이용되며 subclass에서 관련 구현체를 initialize 합니다.
    @dispatched_notifications_service = nil
    @message_template_id = message_template_id

    # 어떤 공고를 통해 발생한 것인지, 파악하기 위한 Id를 받는 변수
    # 각 서브클래스에서 주입
    @job_posting_id_for_notification_results = nil

    message_template = MessageTemplate.find_by(name: message_template_id)
    target_medium = MessageTemplate.find_by(name: message_template_id).nil? ? KAKAO_ARLIMTALK : MessageTemplate.find_by(name: message_template_id).target_medium
    Jets.logger.info "요청하신 #{message_template_id}가 message_templates Table에 존재하지 않습니다." if message_template.nil? & Jets.env.development?
    @target_medium = target_medium
  end

  def create_message
    raise NotImplementedError, "#{self.class}에서 해당 '#{__method__}'를 구현하지 않았습니다. Notification::CreateMessage::CallSavedJobPostingV2를 참고하여 개발해주세요."
  end

  def process
    begin
      notify
      save_result
      create_dispatched_notifications unless @dispatched_notifications_service.nil?
    rescue => e
      Jets.logger.info e.message
    end
  end

  def notify
    send_app_push
    send_bizm_post_pay
    send_bizm_pre_pay
  end


  def save_result
    Jets.logger.info "전체 발송 대상자 : #{@list.nil? ? 0 : @list.count} 명 발송처리 완료"
    # app push 결과 처리
    save_results_app_push(@app_push_result, @message_template_id, @job_posting_id_for_notification_results)
    # post_pay 결과 처리
    save_results_bizm_post_pay(@bizm_post_pay_result, @message_template_id, @job_posting_id_for_notification_results)
    # pre_pay 결과 처리
    save_results_bizm_pre_pay(@bizm_pre_pay_result, @message_template_id, @job_posting_id_for_notification_results)
  end

  def create_dispatched_notifications
    unless @dispatched_notifications_service.nil?
      results = @app_push_result + @bizm_post_pay_result + @bizm_pre_pay_result
      @dispatched_notifications_service.set_dispatced_notifications(results)
    end
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

  def clear_notification_lists
    @app_push_list = []
    @bizm_post_pay_list = []
    @bizm_pre_pay_list = []

    @app_push_result = []
    @bizm_post_pay_result = []
    @bizm_pre_pay_result = []
  end
end