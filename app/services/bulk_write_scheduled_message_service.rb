class BulkWriteScheduledMessageService
  attr_reader :template_id, :send_type

  BATCH_SIZE = 1_500.freeze

  def initialize(template_id, send_type)
    @template_id = template_id
    @send_type = send_type
  end

  def save_call
    return if Jets.env != "production"

    users = find_users
    messages = []

    users.find_each do |user|
      begin
        data = yield(user)

        if data.nil?
          next
        end

        now = Time.now

        messages.push(
          template_id: @template_id,
          send_type: @send_type,
          content: data.dig(:jsonb),
          phone_number: data.dig(:phone_number),
          scheduled_date: data.dig(:scheduled_date),
          created_at: now,
          updated_at: now,
        )

        if messages.length == 100
          ScheduledMessage.insert_all(
            messages
          )
          messages.clear
        end

      rescue => e
        Jets.logger.info e.message
      end
    end

    if messages.present?
      begin
        ScheduledMessage.insert_all(
          messages
        )
      rescue => e
        Jets.logger.info e.full_message
      end

      messages.clear
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
    when MessageTemplateName::NEWSPAPER_V2
      return User.receive_job_notifications.order(:created_at)
    else
      return nil
    end
  end
end