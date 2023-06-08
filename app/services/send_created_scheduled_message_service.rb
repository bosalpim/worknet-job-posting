class SendCreatedScheduledMessageService
  def self.call(template_id, send_type, should_send_percent, sent_percent)
    new.call(template_id, send_type, should_send_percent, sent_percent)
  end

  def call(template_id, send_type, should_send_percent, sent_percent)
    return if Jets.env != "production"

    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []

    total_count = ScheduledMessageCount.where(created_at: 1.days.ago..).where(template_id: template_id).first!.total_count
    counts = calculate_sent_and_message_count(total_count, should_send_percent, sent_percent)
    message_count = counts.dig(:message_count)
    sent_count = counts.dig(:sent_count)

    Jets.logger.info "Calculate Result > message_count : #{message_count}, sent_count: #{sent_count}"

    messages = ScheduledMessage.where(scheduled_date: 1.days.ago..).where(template_id: template_id).where(is_send: false).limit(message_count)
    messages.update_all(is_send: true)

    Jets.logger.info "Read Message Count > #{messages.length}"

    messages.find_each(batch_size: message_count) do |message|
      if should_send(message)
        begin
          response = KakaoNotificationService.call(
            template_id: message.template_id,
            message_type: template_id == KakaoTemplate::JOB_ALARM_ACTIVELY ? 'AI' : 'AT',
            phone: Jets.env != 'production' ? '01094659404' : message.phone_number,
            template_params: JSON.parse(message.content)
          )

          if response.dig("code") == "success"
            if response.dig("message") == "K000"
              success_count += 1
            else
              tms_success_count += 1
            end
          else
            fail_count += 1
          end

          fail_reasons.push(response.dig("originMessage")) if response.dig("message") != "K000"
        rescue => e
          fail_count += 1
          fail_reasons.push(e.message)
          Jets.logger.info e.message
        end
      else
        Jets.logger.info("메세지 전송 당시 상태 변화 #{message.id}")
      end
    end

    Jets.logger.info("전송 개수 : #{ScheduledMessage.where(is_send: true).length}, 미전송 개수 : #{ScheduledMessage.where(is_send: false).length}")

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

  def should_send(message)
    if User.where(phone_number: message.phone_number).where(has_certification: true).where(notification_enabled: true).where('job_search_status < ?', 2).length == 0
      return false
    else
      return true
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