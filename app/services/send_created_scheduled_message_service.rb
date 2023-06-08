class SendCreatedScheduledMessageService
  def self.call(template_id, send_type, should_send_percent, sent_percent)
    new.call(template_id, send_type, should_send_percent, sent_percent)
  end

  def call(template_id, send_type, should_send_percent, sent_percent)
    # return if Jets.env != "production"

    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []

    total_count = ScheduledMessageCount.where(created_at: 9.days.ago..).where(template_id: template_id).first!.total_count
    counts = calculate_sent_and_message_count(total_count, should_send_percent, sent_percent)
    message_count = counts.dig(:message_count)
    sent_count = counts.dig(:sent_count)

    Jets.logger.info "Calculate Result > message_count : #{message_count}, sent_count: #{sent_count}"

    messages = ScheduledMessage.where(scheduled_date: 9.days.ago..).where(template_id: template_id).where(is_send: false).limit(message_count)
    messages.update_all(is_send: true)

    Jets.logger.info "Read Message Count > #{messages.length}"

    messages.each_slice(20) do |batch|
      results = []
      batch.each do |message|
        threads = []
        threads << Thread.new do
          begin
            next if check_sendable(message) == false
            response = KakaoNotificationService.call(
              template_id: message.template_id,
              # message_type: template_id == KakaoTemplate::JOB_ALARM_ACTIVELY ? 'AI' : 'AT',
              message_type: 'AT',
              phone: Jets.env != 'production' ? '01094659404' : message.phone_number,
              template_params: JSON.parse(message.content)
            )

            results.push( { status: 'success', response: response })
          rescue Net::ReadTimeout
            time_out_messages.push(message)
          rescue HTTParty::Error => e
            results.push({ status: 'fail' , response: "#{e.message}"})
          end
        end
        threads.each(&:join)
      end

      parsed_results = process_results(results)
      success_count += parsed_results.dig(:success_count)
      fail_count += parsed_results.dig(:fail_count)
      tms_success_count += parsed_results.dig(:tms_success_count)
      fail_reasons.concat(parsed_results.dig(:fail_reasons))
    end

    if time_out_messages.length > 0
    end

    Jets.logger.info("전송 개수 : #{ScheduledMessage.where(is_send: true).length}, 미전송 개수 : #{ScheduledMessage.where(is_send: false).length}")
    Jets.logger.info("알림톡 전송 개수 : #{success_count}, 문자 전송 개수 : #{tms_success_count}, 실패 개수 : #{fail_count}")

    KakaoNotificationResult.create!(
      send_type: send_type,
      send_id: "#{(should_send_percent + sent_percent) * 100}%",
      template_id: template_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons.uniq.join(", ")
    )
  end

  def process_results(results)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []

    results.each do |result|
      response = result.dig(:response)
      status = result.dig(:status)

      if status == 'fail'
        fail_count += 1
        fail_reasons.push(response)
        Jets.logger.info response
      else
        if response.dig("code") == "success"
          if response.dig("message") == "K000"
            success_count += 1
          else
            fail_reasons.push(response.dig("originMessage"))
            tms_success_count += 1
          end
        else
          fail_count += 1
        end
      end
    end
    
  end

  def check_sendable(message)
    if User.where(phone_number: message.phone_number).where(has_certification: true).where(notification_enabled: true).where('job_search_status < ?', 2).length == 0
      return false
    else
      return message.is_send == false
    end
  end

  def calculate_sent_and_message_count(total_count, should_send_percent, sent_percent)
    message_count = (total_count * should_send_percent).ceil
    sent_count = (total_count * sent_percent).ceil

    next_send_count = (total_count * (should_send_percent + sent_percent)).ceil
    message_count -= 1 if message_count + sent_count > next_send_count

    return {
      message_count: message_count,
      sent_count: sent_count
    }
  end
end