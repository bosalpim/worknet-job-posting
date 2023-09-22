class CreateScheduledMessageService
  attr_reader :template_id, :send_type

  BATCH_SIZE = 1_500.freeze

  def initialize(template_id, send_type)
    @template_id = template_id
    @send_type = send_type
  end

  def save_call
    return if Jets.env != "production"
    users = find_users

    users.find_each do |user|
      begin
        data = yield(user)
        ScheduledMessage.create!(
          template_id: @template_id,
          send_type: @send_type,
          content: data.dig(:jsonb),
          phone_number: data.dig(:phone_number),
          scheduled_date: data.dig(:scheduled_date)
        ) unless data.nil?
      rescue => e
        Jets.logger.info e.message
      end
    end

    total_count = ScheduledMessage.where(template_id: @template_id).where(scheduled_date: 1.days.ago..).size
    ScheduledMessageCount.create!(
      template_id: @template_id,
      total_count: total_count
    )
  end

  private

  def find_users
    case template_id
    when KakaoTemplate::JOB_ALARM_ACTIVELY, KakaoTemplate::NEWSPAPER_V2
      return User.receive_job_notifications.order(:created_at)
    else
      return nil
    end
  end
end