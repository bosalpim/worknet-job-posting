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
    when KakaoTemplate::HIGH_SALARY_JOB
      return User.where(status: 'draft')
                 .where(has_certification: true)
                 .where(notification_enabled: true) # 이 값을 언제 받는지 ? 광고성임을 알려주어야 하는지
                 .where.not(draft_status: 'address')
                 .where("created_at >= ?", 1.day.ago)
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
              phone: Jets.env == "production" ? user.phone_number : '01094659404',
              message_type: "AI",
              template_params: { name: user.name }
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
    when KakaoTemplate::HIGH_SALARY_JOB
      KakaoNotificationResult::HIGH_SALARY_JOB
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
        fail_reasons.push("userid : #{user.id} #{response}")
      else
        if response.dig("result") == "Y"
          if response.dig("code") == "K000"
            success_count += 1
          else
            fail_reasons.push("userid : #{user.id} #{response.dig("error")}")
            tms_success_count += 1
          end
        else
          fail_count += 1
        end
      end
    end

    current_date = DateTime.now
    KakaoNotificationResult.create!(
      send_type: get_send_type,
      send_id: "#{current_date.year}/#{current_date.month}/#{current_date.day}#{@template_id}",
      template_id: KakaoTemplate::HIGH_SALARY_JOB,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons
    )
  end
end