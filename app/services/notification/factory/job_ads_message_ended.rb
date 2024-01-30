class Notification::Factory::JobAdsMessageEnded < Notification::Factory::NotificationFactoryClass
  include ApplicationHelper
  include TranslationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper
  include DispatchedNotificationsHelper
  include NotificationType

  def initialize(job_posting_id)
    super(MessageTemplateName::JOB_ADS_ENDED)
    job_posting = JobPosting.find(job_posting_id)
    @job_posting = job_posting

    business_client = BusinessClient.find_by(business_id: job_posting.business_id)
    client = Client.find_by(id: business_client.client_id)
    @list = [client]

    create_message
  end

  def create_message
    @list.each do |client|
      create_bizm_post_pay_message(client)
    end
  end

  def create_bizm_post_pay_message(client)
    dispatched_notifications = DispatchedNotification.where(notification_relate_instance_types_id: RELATE_TYPE_JOB_POSTING, notification_relate_instance_id: @job_posting.id)
    confirmed_notifications = dispatched_notifications.where.not(confirmed: nil)
    base_url = business_base_url
    utm = "?utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    close_link = "#{base_url}/recruitment_management/#{@job_posting.public_id}/close#{utm}"
    result_link = "#{base_url}/recruitment_management/#{@job_posting.public_id}/dashboard#{utm}"

    params = {
      title: "구인 광고 메세지 발송완료",
      message: build_message(dispatched_notifications.count, confirmed_notifications.count),
      close_link: close_link,
      result_link: result_link,
      job_posting_public_id: @job_posting.public_id,
      job_posting_title: @job_posting.title,
      target_public_id: client.public_id
    }

    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, @job_posting.manager_phone_number, params, client.public_id, 'AI'))
  end

  def build_message(dispatched_notifications_count, confirmed_notifications_count)
    "1~3차 구인 광고 메세지를 모두 발송했어요.

■ 공고제목
#{@job_posting.title}

■ 발송 내역
지금까지 #{get_dong_name_by_address(@job_posting.address)} 주변 요양보호사 #{dispatched_notifications_count}명이 메세지를 받았고, #{confirmed_notifications_count}명이 공고를 확인했어요.

■ 채용 했나요?
구인광고 메세지를 보고 계속해서 지원, 문의 연락을 받을 수 있어요. 구인 완료했다면 채용 종료해주세요."
  end
end