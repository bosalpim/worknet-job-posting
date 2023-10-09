class Notification::ResultProcessService
  include ApplicationHelper
  def self.process_result(template_id, process_results)
    check_process_result(process_results.first)
    new.process_result(template_id, process_results)
  end

  def process_result(template_id, process_results)
    grouped_data = process_results.group_by { |item| item[:send_medium] }

    ## 여기부터 메세지 2개이상 발송되었을 때를 처리해본다.
    grouped_data.each do |send_medium, items|
      extracted_data = items.map do |item|
        item[:response]
      end

      case send_medium
      when NotificationServiceJob::BIZM_POST_PAY
        process_results(extracted_data, template_id)
      when NotificationServiceJob::APP_PUSH
        process_results(extracted_data, template_id)
      else
        raise "대상 템플릿 : #{template_id}, #{send_medium} 발송결과 DB 저장 처리가 대응되지 않았습니다."
      end
    end
  end

  def self.check_process_result(process_result)
    return if process_result.nil?
    unless process_result.is_a?(Hash) && process_result.key?(:response) && process_result.key?(:send_medium)
      raise ArgumentError, "process_results should be a hash with :response, :template_params, and :send_medium keys."
    end
  end
end