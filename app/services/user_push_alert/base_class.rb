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
      disable_old_alerts

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
            # 각 사용자별로 현재 최대 시퀀스 번호 조회
            user_ids = slice.map(&:id)

            # 각 사용자의 기존 최대 시퀀스 값 조회
            existing_sequences = UserPushAlertQueue
                                   .where(alert_id: alert.id, date: @date, user_id: user_ids)
                                   .group(:user_id)
                                   .maximum(:sequence)

            # 증가된 시퀀스 번호로 레코드 생성
            records = slice.map do |user|
              # 현재 최대값 조회 (기존 레코드가 없으면 nil을 반환)
              current_max = existing_sequences[user.id]

              # 새 시퀀스 값 설정 (기존 레코드가 있으면 max+1, 없으면 1)
              new_sequence = current_max ? current_max + 1 : 1

              {
                date: @date,
                group: offset / batch_size,
                status: 'pending',
                user_id: user.id,
                alert_id: alert.id,
                push_token: user.push_token&.token,
                sequence: new_sequence
              }
            end

            UserPushAlertQueue.insert_all(records)
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

  def disable_old_alerts
    begin
      # 혜택페이지에 접근한지 2주 이상 지난 알림 동의를 찾아서 삭제
      disabled_count = UserAlertAgreed.joins(:alert)
                    .joins("LEFT JOIN user_alert_page_visits ON user_alert_agreed.user_id = user_alert_page_visits.user_id AND user_alert_page_visits.alert_id = user_alert_agreed.alert_id")
                    .where(alerts: { name: @alert_name })
                    .where(
                      ["user_alert_page_visits.last_visited_at < ? AND user_alert_page_visits.last_visited_at IS NOT NULL", 2.weeks.ago]
                    )
                    .delete_all

      log disable_message(disabled_count)
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
