class PercentUserNotificationService
  attr_reader :should_send_percent, :sent_percent, :send_type, :template_id

  BATCH_SIZE = 1_500.freeze # find_each's default batch size is 1,000

  def initialize(should_send_percent, sent_percent, send_type, template_id)
    @should_send_percent = should_send_percent
    @sent_percent = sent_percent
    @send_type = send_type
    @template_id = template_id
  end

  def percent_call
    users = User.active.receive_notifications.where(has_certification: true).order(:created_at)
    total_count = users.size
    message_count = (total_count * should_send_percent).ceil
    sent_count = (total_count * sent_percent).ceil

    next_send_count = (total_count * (should_send_percent + sent_percent)).ceil
    message_count -= 1 if message_count + sent_count > next_send_count

    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []
    users = test_users(users) if Jets.env == "staging" # WARNING 바꾸면 실제 유저에게 배포됨
    users.offset(sent_count).limit(message_count).find_each(batch_size: BATCH_SIZE) do |user|
      begin
        response = yield(user)
        next if response.nil?
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

  private

  def test_users(users)
    users.where(phone_number: %w[])
  end
end