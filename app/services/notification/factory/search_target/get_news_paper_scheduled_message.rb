class Notification::Factory::SearchTarget::GetNewsPaperScheduledMessage
  def self.call(template_id, should_send_percent, sent_percent)
    new.call(template_id, should_send_percent, sent_percent)
  end

  def call(template_id, should_send_percent, sent_percent)
    message_created_time = 1

    total_count = ScheduledMessageCount.where(created_at: message_created_time.days.ago..).where(template_id: template_id).first!.total_count
    counts = calculate_sent_and_message_count(total_count, should_send_percent, sent_percent)
    message_count = counts.dig(:message_count)
    sent_count = counts.dig(:sent_count)

    Jets.logger.info "Calculate Result > message_count : #{message_count}, sent_count: #{sent_count}"

    messages = ScheduledMessage.where(scheduled_date: message_created_time.days.ago..).where(template_id: template_id).order(:scheduled_date).offset(sent_count).limit(message_count)
    messages.update_all(is_send: true)
    messages.filter do |message|
      message.sendable
    end
  end

  private
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