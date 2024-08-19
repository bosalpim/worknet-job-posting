# frozen_string_literal: true

class Newspaper::PrepareAlldayService
  def initialize(
    date: DateTime.now,
    batch: 3000
  )
    @batch = batch
    @date = date.tomorrow.at_beginning_of_day.strftime('%Y/%m/%d')
    @users = fetch_users
    @count = @users.count
  end

  def call
    begin
      log start_message

      @users.find_in_batches(
        batch_size: @batch
      ).each_with_index do |batch, index|
        begin
          batch.each_slice(500) do |slice|
            Newspaper
              .insert_all(
                slice.map { |user| { date: @date, group: index, status: 'pending', user_id: user.id, push_token: user.push_token&.token } }
              )
          end
        rescue => e
          Jets.logger.error e
        end

      end

      log end_message
    rescue => e
      log error_message e
    end

  end

  private

  def fetch_users
    yesterday_start = DateTime.now.yesterday.beginning_of_day
    yesterday_end = DateTime.now.yesterday.end_of_day

    # 어제 생성된 job_postings를 필터링
    job_postings = JobPosting
                     .where('created_at >= ? AND created_at <= ?', yesterday_start, yesterday_end)

    User
      .receive_job_notifications
      .where
      .not(phone_number: nil)
      .where('id % 2 = 0') # 짝수 ID만 선택
      .select do |user|
        within_radius_count = job_postings.within_radius(3000, user.lat, user.lng).count
        within_radius_count > 0
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
