# frozen_string_literal: true

class Newspaper::PrepareService
  def initialize(
    date: DateTime.now,
    batch: 3000
  )
    @batch = batch
    @date = date.tomorrow.at_beginning_of_day.strftime('%Y/%m/%d')
    @user_with_counts = fetch_users  # -> [[user, count], [user, count], ...]
    @count = @user_with_counts.count
  end

  def call
    begin
      log start_message

      total_users = @user_with_counts.size
      batch_size = @batch

      (0...total_users).step(batch_size) do |offset|
        batch = @user_with_counts[offset, batch_size]
        batch.each_slice(500) do |slice|
          begin
            Newspaper.insert_all(
              slice.map do |user_count_pair|
                user, job_count = user_count_pair
                {
                  date:         @date,
                  group:        offset / batch_size,
                  status:       'pending',
                  user_id:      user.id,
                  push_token:   user.push_token&.token,
                  yesterday_job_count: job_count
                }
              end
            )
          rescue => e
            Jets.logger.error e
          end
        end
      end

      log end_message

      Newspaper
        .where("date < ?", 1.week.ago)
        .delete_all
    rescue => e
      log error_message e
    end
  end

  private

  # 마지막 접속일이 4주 경과했다면 알림 off
  def update_job_notification_enabled
    four_weeks_ago = DateTime.now - 28.days
    User
      .where('last_used_at <= ?', four_weeks_ago)
      .update_all(job_notification_enabled: 'false')
  end

  # 최근 접속일이 1주일 이내라면 매일 발송.
  # 최근 접속일이 1주일 이상 경과했다면 마지막 접속일로부터 1주일 단위로 발송
  def should_send_notification?(last_use_at, today)
    return false if last_use_at.nil?

    days_since_last_use = (today.to_date - last_use_at.to_date).to_i

    if days_since_last_use <= 7
      # 최근 7일 이내 접속: 매일 알림 발송
      true
    elsif days_since_last_use <= 28 && days_since_last_use % 7 == 0
      # 최근 접속일로부터 7, 14, 21, 28일째 되는 날: 알림 발송
      true
    else
      # 그 외의 경우: 알림 발송하지 않음
      false
    end
  end

  def fetch_users
    today = DateTime.now
    yesterday_start = if today.sunday?
                        today.ago(2.days).beginning_of_day
                      else
                        today.beginning_of_day
                      end
    yesterday_end = today.end_of_day

    update_job_notification_enabled

    users = User
              .receive_job_notifications
              .where.not(phone_number: nil)
              .select do |user|
      should_send_notification?(user.last_used_at, today)
    end

    users.map do |user|
      job_postings_count = JobPosting
                             .where('created_at >= ? AND created_at <= ?', yesterday_start, yesterday_end)
                             .within_radius(3000, user.lat, user.lng)
                             .where(work_type: user.preferred_work_types)
                             .count

      [user, job_postings_count]
    end
  end

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
            text: "일자리신문 생성 시작"
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
            text: "일자리신문 생성 종료"
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
            text: "일자리신문 생성 오류"
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
