# frozen_string_literal: true

class JobPostingJob < ApplicationJob
  include Notification

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
  def send_second_job_ads_message
    begin
      target_id =
        MessageHistory.where(type_name: TYPE_RESERVED, notification_relate_instance_types_id: 1, status: 2, is_cancel: [false,nil])
                      .where('scheduled_at >= ? AND scheduled_at <= ?', 1.hour.ago, 1.hour.from_now)
                      .pluck(:notification_relate_instance_id)

      job_postings = JobPosting.where(id: target_id)

      job_postings.each do |job_posting|
        Jets.logger.info "#{job_posting.public_id} | #{job_posting.title} 2차 구인광고 메세지 발송처리 시작"
        notification = Notification::FactoryService.create(MessageTemplateName::JOB_ADS_MESSAGE_SECOND, { job_posting_id: job_posting.id })
        notification.process

        MessageHistory.create!(type_name: TYPE_SUCCEDED, status: 2, notification_relate_instance_types_id: RELATE_TYPE_JOB_POSTING, notification_relate_instance_id: job_posting.id)
        scheduled_at = Time.current.tomorrow.beginning_of_day + 8.hours
        MessageHistory.create!(type_name: TYPE_RESERVED, status: 3, notification_relate_instance_types_id: RELATE_TYPE_JOB_POSTING, notification_relate_instance_id: job_posting.id, scheduled_at: scheduled_at)

        # 3차 메세지 예약 알림톡 발송
        reserve_notification = Notification::FactoryService.create(MessageTemplateName::JOB_ADS_MESSAGE_RESERVE, { job_posting_id: job_posting.id, times: 3, scheduled_at_text: (scheduled_at).strftime('%m월 %d일 %I시 %M분') })
        reserve_notification.process
      end
    rescue => e
      Jets.logger.info e.message
    end
  end

  cron "5 23 * * ? *"
  def send_third_job_ads_message
    begin
      target_id =
        MessageHistory.where(type_name: TYPE_RESERVED, notification_relate_instance_types_id: 1, status: 3, is_cancel: [false,nil])
                      .where('scheduled_at >= ? AND scheduled_at <= ?', 1.hour.ago, 1.hour.from_now)
                      .pluck(:notification_relate_instance_id)

      job_postings = JobPosting.where(id: target_id)

      job_postings.each do |job_posting|
        Jets.logger.info "#{job_posting.public_id} | #{job_posting.title} 3차 구인광고 메세지 발송처리 시작"
        notification = Notification::FactoryService.create(MessageTemplateName::JOB_ADS_MESSAGE_THIRD, { job_posting_id: job_posting.id })
        notification.process

        MessageHistory.create!(type_name: TYPE_SUCCEDED, status: 3, notification_relate_instance_types_id: 1, notification_relate_instance_id: job_posting.id)
        MessageHistory.create!(type_name: TYPE_COMPLETED, notification_relate_instance_types_id: 1, notification_relate_instance_id: job_posting.id)

        # 예약 메세지 발송 모두 처리 완료
        reserve_notification = Notification::FactoryService.create(MessageTemplateName::JOB_ADS_ENDED, { job_posting_id: job_posting.id })
        reserve_notification.process
      end
    rescue => e
      Jets.logger.info e.message
    end
  end
end
