class Notification::Factory::JobAdsMessageReserve < Notification::Factory::NotificationFactoryClass
  include ApplicationHelper
  include TranslationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper
  include DispatchedNotificationsHelper

  def initialize(job_posting_id, times, scheduled_at_text)
    super(MessageTemplateName::JOB_ADS_MESSAGE_RESERVE)
    job_posting = JobPosting.find(job_posting_id)
    @job_posting = job_posting
    @times = times
    @scheduled_at_text = scheduled_at_text

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
    dispatched_notifications = DispatchedNotification.where(notification_relate_instance_types_id: 1, notification_relate_instance_id: @job_posting.id)
    base_url = business_base_url
    utm = "?utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    cancel_message_link = "#{base_url}/recruitment_management/#{@job_posting.public_id}/cancel_message#{utm}"
    result_link = "#{base_url}/recruitment_management/#{@job_posting.public_id}/dashboard#{utm}"

    params = {
      title: "구인 광고 메세지 예약",
      message: build_message(dispatched_notifications.count),
      cancel_message_link: cancel_message_link,
      result_link: result_link,
      job_posting_public_id: @job_posting.public_id,
      job_posting_title: @job_posting.title,
      target_public_id: client.public_id
    }

    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, @job_posting.manager_phone_number, params, client.public_id, 'AI'))
  end

  def build_message(dispatched_notifications_count)
    "#{@scheduled_at_text}에 구인 광고 메세지를 #{@times}차 발송할 예정이에요.

■ 공고제목
#{@job_posting.title}

■ 발송 내역
지금까지 #{get_dong_name_by_address(@job_posting.address)} 주변 요양보호사 #{dispatched_notifications_count}명이 메세지를 받았어요. 자세한 내용은 발송 결과보기 버튼을 눌러 확인해 보세요.

■ 이미 채용 했나요?
구인광고 메세지를 보고 계속해서 지원, 문의 연락을 받을 수 있어요. 이미 채용했다면 채용 종료하여 발송 취소해주세요."
  end
end