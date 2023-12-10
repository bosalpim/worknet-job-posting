# frozen_string_literal: true

class JobPostingJob < ApplicationJob

  cron "0 1 * * ? *"

  def notify_expiration_date(date = nil)
    now = date.nil? ? DateTime.now : date

    JobPosting::NotifyExpirationDateService.call(
      DateTime.new(
        now.year,
        now.month,
        now.day, 1, 0, 0
      ).in_time_zone('Seoul')
    )
  end

  cron "0 23 * * ? *"
  def send_job_ads_message_second
    target_id =
      MessageHistory.where(type_name: 'reserved', notification_relate_instance_types_id: 1, status: 2, is_cancel: nil)
                    .where('scheduled_at >= ? AND scheduled_at <= ?', 1.hour.ago, 1.hour.from_now)
                    .pluck(:notification_relate_instance_id)

    job_postings = JobPosting.where(id: target_id)

    job_postings.each do |job_posting|
      Jets.logger.info "#{job_posting.public_id} | #{job_posting.title} 2차 구인광고 메세지 발송처리 시작"
      notification = Notification::FactoryService.create(MessageTemplateName::JOB_ADS_MESSAGE_SECOND, { job_posting_id: job_posting.id })
      notification.process

      MessageHistory.create!(type_name: "completed", status: 2, notification_relate_instance_types_id: 1, notification_relate_instance_id: job_posting.id)
      scheduled_at = Time.current.tomorrow.beginning_of_day + 8.hours
      MessageHistory.create!(type_name: "reserved", status: 3, notification_relate_instance_types_id: 1, notification_relate_instance_id: job_posting.id, scheduled_at: scheduled_at)

      # 3차 메세지 예약 알림톡 발송
      reserve_notification = Notification::FactoryService.create(MessageTemplateName::JOB_ADS_MESSAGE_RESERVE, { job_posting_id: job_posting.id, times: 3, scheduled_at_text: (scheduled_at).strftime('%m월 %d일 %I시 %M분') })
      reserve_notification.process
    end
  end

  cron "5 23 * * ? *"
  def send_job_ads_message_third

  end
end
