class SendNewsPaperService
  attr_reader :job_search_status

  def initialize(job_search_status)
    @job_search_status = job_search_status
  end

  def call
    case job_search_status
    when User::job_search_statuses.dig(:actively)
      users = NewsPaper::find_target_user_by_csv('news_paper_target/job_search_status_actively.csv', job_search_status)
      send_message(users, KakaoTemplate::JOB_ALARM_ACTIVELY)
    when User::job_search_statuses.dig(:commonly)
      users = NewsPaper::find_target_user_by_csv('news_paper_target/job_search_status_commonly', job_search_status)
      send_message(users, KakaoTemplate::JOB_ALARM_COMMON)
    when User::job_search_statuses.dig(:off)
      users = User.off
                  .where(has_certification: true)
                  .where(notification_enabled: true)
      send_message(users, KakaoTemplate::JOB_ALARM_OFF)
    when User::job_search_statuses.dig(:working)
      users = User.working
                  .where(has_certification: true)
                  .where(notification_enabled: true)
      send_message(users, KakaoTemplate::JOB_ALARM_WORKING)
    end
  end

  private

  def send_message(users, template_id)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []

    users.each do |user|
      response = KakaoNotificationService.call(
        template_id: template_id,
        phone: Jets.env != 'production' ? '01094659404' : user.phone_number,
        template_params: {}
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
    end

    KakaoNotificationResult.create!(
      send_type: KakaoNotificationResult::NEWS_PAPER,
      template_id: template_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons.uniq.join(", ")
    )
  end
end