class Notification::ResultProcessService
  include ApplicationHelper
  def self.process_result(template_id, process_results)
    check_process_result(process_results.first)
    new.process_result(template_id, process_results)
  end

  def process_result(template_id, process_results)
    grouped_data = process_results.group_by { |item| item[:send_medium] }

    grouped_data.each do |send_medium, items|
      case send_medium
      when NotificationServiceJob::BIZM_POST_PAY
        process_results(items, template_id)
      else
        raise "대상 템플릿 : #{template_id}, #{send_medium} 발송결과 DB 저장 처리가 대응되지 않았습니다."
      end
      items.each { |item| puts "- #{item[:name]}" }
    end
  end

  def self.check_process_result(process_result)
    return if process_result.nil?
    unless process_result.is_a?(Hash) && process_result.key?(:response) && process_result.key?(:send_medium)
      raise ArgumentError, "process_results should be a hash with :response, :template_params, and :send_medium keys."
    end
  end
end