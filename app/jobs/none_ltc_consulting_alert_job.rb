class NoneLtcConsultingAlertJob < ApplicationJob
  cron "0 1 * * ? *"
  def morning_job
    process
  end

  cron "0 6 * * ? *"
  def afternoon_job
    process
  end

  def process
    before_consulting_list_count = before_consulting_list.count
    reminds_list_count = reminds_list.count

    notification_payload = {
      text: "<!subteam^S06CS6SGU9G|guardian_biz>",
      attachments: [
        {
          title: '오늘자 비급여 상담리스트',
          title_link: 'https://bo.carepartner.kr/none-ltc-service-requests/urgent',
          fields: [
            {
              title: '상담 필요',
              value: "#{before_consulting_list_count} 개",
              short: false,
            },
            {
              title: '재연락 필요',
              value: "#{reminds_list_count} 개",
              short: false,
            },
          ],
          footer: '콜백알림봇',
          footer_icon: 'https://platform.slack-edge.com/img/default_application_icon.png',
        }
      ]
    }

    SlackWebhookService.call(:none_ltc_consulting_alert, notification_payload)
  end

  private
  def before_consulting_list
    # created_at 기준으로 오늘 이전날짜 before_consulting + 오늘 상담 요청건들
    NoneLtcServiceRequest
      .where.not(service_plan: %w[few_days once])
      .or(NoneLtcServiceRequest.where(service_plan: nil))
      .where(status: 'before_consulting')
      .before_end_of_today
      .order(
        "created_at desc"
      )
  end

  # 오늘 리마인드 하기로한 상담건들
  def reminds_list
    ids = NoneLtcServiceRequestsConsultingRemind
            .before_end_of_today
            .where.not(status: 'finish')
            .pluck(:none_ltc_service_request_id)

    NoneLtcServiceRequest
      .where.not(service_plan: %w[few_days once])
      .or(NoneLtcServiceRequest.where(service_plan: nil))
      .where(id: ids)
      .order(
        "created_at desc"
      )
  end

end