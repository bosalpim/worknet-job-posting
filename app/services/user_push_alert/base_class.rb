# frozen_string_literal: true

class UserPushAlert::BaseClass

  def initialize(
    alert_name: "",
    date: DateTime.now,
    batch: 3000
  )
    @batch = batch
    @date = date.at_beginning_of_day.strftime('%Y/%m/%d')
    @alert_name = alert_name
  end

  def prepare
    begin
      users = User.joins(:alerts, :user_push_tokens)
                  .where(alerts: { name: @alert_name })
                  .distinct

      @count = users.count

      log start_message

      alert = Alert.where(name: @alert_name).first

      total_users = users.size
      batch_size = @batch

      (0...total_users).step(batch_size) do |offset|
        batch = users[offset, batch_size]
        batch.each_slice(500) do |slice|
          begin
            UserPushAlertQueue.insert_all(
              slice.map { |user| { date: @date, group: offset / batch_size, status: 'pending', user_id: user.id, alert_id: alert.id, push_token: user.push_token&.token } }
            )
          rescue => e
            Jets.logger.error e
          end
        end
      end

      log end_message

      UserPushAlertQueue
        .where(alert_id: alert.id)
        .where("date < ?", 1.week.ago)
        .delete_all
    rescue => e
      log error_message e
    end
  end

  private

  def log(message)
    SlackWebhookService.call(:newspaper, message) if message.present?
    Jets.logger.info message if message.present?
  end

  def start_message
    {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: "#{@alert_name} 푸시 발송 생성 시작"
          }
        },
        {
          type: 'context',
          elements: [
            {
              type: 'plain_text',
              text: "🗓️발송예정일자: #{@date}"
            },
            {
              type: 'plain_text',
              text: "👥 발송대상유저수: #{@count}"
            }
          ],
        },
      ],
    }
  end

  def end_message
    {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: "#{@alert_name} 푸시 생성 종료"
          }
        },
        {
          type: 'context',
          elements: [
            {
              type: 'plain_text',
              text: "🗓️발송예정일자: #{@date}"
            },
            {
              type: 'plain_text',
              text: "👥 발송대상유저수: #{@count}"
            }
          ],
        },
      ],
    }
  end

  def error_message(e = StandardError.new)
    {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: "#{@alert_name} 푸시 생성 오류"
          }
        },
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: '<@U0585GV1HK2>'
          }
        },
        {
          type: 'context',
          elements: [
            {
              type: 'mrkdwn',
              text: "```
#{e.message}
```"
            },
          ]
        },
      ],
    }
  end

end
