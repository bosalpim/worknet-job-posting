class SendCreatedScheduledMessageService
  BATCH_SIZE = 100.freeze

  def self.call(template_id, send_type)
    new.call(template_id, send_type)
  end

  def call(template_id, send_type)
    messages = ScheduledMessage.where(scheduled_time: 1.days.ago).where(template_id: template_id)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []

    messages.find_each(batch_size: BATCH_SIZE) do |message|
      begin
        response = KakaoNotificationService.call(
          template_id: message.template_id,
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
    end

    KakaoNotificationResult.create!(
      send_type: send_type,
      send_id: "#{should_send_percent * 100}%",
      template_id: template_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons.uniq.join(", ")
    )
  end
end