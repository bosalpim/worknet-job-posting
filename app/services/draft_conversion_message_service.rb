class DraftConversionMessageService
  def self.call(template_id)
    new.call(template_id)
  end

  def call(template_id)
    return if Jets.env != "production"

    @template_id = template_id

    # user
    users = find_target_user

    # batch
    results = send_message(users)

    # process result
    process_results(results)
  end

  private
  def find_target_user
    case @template_id
    when MessageTemplate::HIGH_SALARY_JOB
      start_time = Time.now.beginning_of_day # 오늘 날짜 00시
      end_time = 1.day.ago.beginning_of_day  # 어제 날짜 00시
      return User.where(created_at: end_time..start_time)
                 .where.not(marketing_agree: nil)
                 .where(notification_enabled: true)
                 .where(status: 'draft')
                 .where(has_certification: true)
                 .where.not(draft_status: 'address')
    when MessageTemplate::ENTER_LOCATION
      start_time = Time.now.beginning_of_day # 오늘 날짜 00시
      end_time = 1.day.ago.beginning_of_day  # 어제 날짜 00시
      return User.where(created_at: end_time..start_time)
                 .where.not(marketing_agree: nil)
                 .where(notification_enabled: true)
                 .where(status: 'draft')
                 .where(has_certification: true)
                 .where(draft_status: 'address')
    when MessageTemplate::WELL_FITTED_JOB
      start_time = 1.day.ago.beginning_of_day# 1일전 날짜 00시
      end_time = 2.day.ago.beginning_of_day  # 2일전 날짜 00시
      return User.where(created_at: (end_time..start_time))
                 .where.not(marketing_agree: nil)
                 .where(notification_enabled: true)
                 .where(status: 'draft')
                 .where(has_certification: true)
    when MessageTemplate::CERTIFICATION_UPDATE
      users = User.where(has_certification: false)
                  .where.not(expected_acquisition: nil)
                  .where.not(marketing_agree: nil)
                  .where(notification_enabled: true)
                  .where(status: 'active')

      filtered_users = users.filter do |user|
        user_expect_acqusition_date = Date.parse(user.expected_acquisition) rescue nil
        today = Date.today
        three_days_ago = today - 3
        seven_days_ago = today - 7

        if three_days_ago == user_expect_acqusition_date || seven_days_ago == user_expect_acqusition_date
          user
        else
          nil
        end
      end

      return filtered_users
    else
      return []
    end
  end

  def send_message(users)
    results = []

    users.each_slice(10) do |batch|
      threads = []

      batch.each do |user|
        threads << Thread.new do
          begin
            rsp = BizmsgService.call(
              template_id: @template_id,
              phone: user.phone_number,
              message_type: "AI",
              template_params: { name: user.name, target_public_id: user.public_id }
            )

            results.push({ status: 'success', response: rsp, user: user })
          rescue Net::ReadTimeout
            msg = "#{user.id} 번 유저 draft 전환 유도 메세지 발송 실패"
            Jets.logger.info msg
            results.push({ status: 'fail', response: "NET::TIMEOUT", user: user })
          rescue HTTParty::Error => e
            results.push({ status: 'fail', response: "#{e.message}", user: user })
          end
        end
      end

      threads.each(&:join)
    end

    results
  end

  def get_send_type
    case @template_id
    when MessageTemplate::HIGH_SALARY_JOB
      KakaoNotificationResult::HIGH_SALARY_JOB
    when MessageTemplate::ENTER_LOCATION
      KakaoNotificationResult::ENTER_LOCATION
    when MessageTemplate::WELL_FITTED_JOB
      KakaoNotificationResult::WELL_FITTED_JOB
    when MessageTemplate::CERTIFICATION_UPDATE
      KakaoNotificationResult::CERTIFICATION_UPDATE
    else
      ""
    end
  end

  def process_results(results)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []

    results.each do |result|
      status = result.dig(:status)
      user = result.dig(:user)
      response = result.dig(:response)

      if status == 'fail'
        fail_count += 1
        fail_reasons.push("userid : #{user.public_id} #{response}")
      else
        if response.dig("result") == "Y"
          if response.dig("code") == "K000"
            success_count += 1
          else
            fail_reasons.push("userid : #{user.public_id}, error: #{response.dig("error")}")
            tms_success_count += 1
          end
        else
          fail_reasons.push("userid : #{user.public_id}, error: #{response.dig("error")}")
          fail_count += 1
        end
      end
    end

    current_date = DateTime.now
    KakaoNotificationResult.create!(
      send_type: get_send_type,
      send_id: "#{current_date.year}/#{current_date.month}/#{current_date.day}#{@template_id}",
      template_id: @template_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons
    )
  end
end