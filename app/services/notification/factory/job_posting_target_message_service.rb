class Notification::Factory::JobPostingTargetMessageService < Notification::Factory::NotificationFactoryClass

  include ApplicationHelper
  include TranslationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper
  include DispatchedNotificationsHelper

  JobPostingTargetUserService = Notification::Factory::SearchTarget::JobPostingTargetUserService
  DispatchedNotificationService = Notification::Factory::DispatchedNotifications::Service

  def initialize(params)
    super(MessageTemplateName::TARGET_USER_JOB_POSTING)
    @params = params
    job_posting_id = params[:job_posting_id]
    job_posting = JobPosting.find(job_posting_id)
    @job_posting = job_posting
    @end_point = "/jobs/#{@job_posting.public_id}"
    @job_posting_id_for_notification_results = job_posting.id
    @list = JobPostingTargetUserService.call(@job_posting.lat, @job_posting.lng)
    @dispatched_notifications_service = DispatchedNotificationService.call(@message_template_id, "target_message", @job_posting.id, "yobosa")
    @fail_alert_message_payload = {
      text: '동네광고 전송 실패!',
      attachments: [
        {
          fallback: '전송 실패!',
          color: '#A7B8A3',
          title: '동네광고 전송 샐패',
          fields: [
            {
              title: '기관명',
              value: @job_posting.business.name,
              short: false,
            },
            {
              title: '공고명',
              value: @job_posting.title,
              short: false,
            },
          ],
        }
      ]
    }
    create_message
  end

  def create_message
    @list.each do |user|
      dispatched_notification_param = create_dispatched_notification_params(@message_template_id, "target_message", @job_posting.id, "yobosa", user.id, "job_detail")
      application_notification_param = create_dispatched_notification_params(@message_template_id, "target_message", @job_posting.id, "yobosa", user.id, "application")
      create_bizm_post_pay_message(user, dispatched_notification_param, application_notification_param) if Jets.env == 'production' || (Main::Application::PHONE_NUMBER_WHITELIST.is_a?(Array) && Main::Application::PHONE_NUMBER_WHITELIST.include?(user.phone_number))
    end
  end

  private
  def create_bizm_post_pay_message(user, dispatched_notification_param, application_notification_param)
    base_url = if Jets.env.production?
                            "http://www.carepartner.kr"
                          elsif Jets.env.staging?
                            "http://www.dev-carepartner.kr"
                          else
                            "http://localhost:3000"
                          end
    view_endpoint = "#{@end_point}?utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}&lat=#{user.lat}&lng=#{user.lng}" + dispatched_notification_param
    origin_url = "#{base_url}#{view_endpoint}"
    application_url = "#{base_url}/jobs/#{@job_posting.public_id}/application?utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}" + application_notification_param

    params = {
      title: "일자리 동네 광고",
      job_posting_id: @job_posting.id,
      job_posting_public_id: @job_posting.public_id,
      job_posting_title: @job_posting.title,
      business_name: @job_posting.business.name,
      job_posting_type: translate_type('job_posting', @job_posting, :work_type),
      send_at: Time.current + (9 * 60 * 60),
      message: build_visit_message(user),
      origin_url: origin_url,
      application_url: application_url,
      target_public_id: user.public_id
    }

    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, user.phone_number, params, user.public_id, 'AI'))
  end

  def build_visit_message(user)
    "#{@job_posting.title}
    
■ 근무지
#{@job_posting.address}

■ 예상 통근거리
#{user.simple_distance_from_ko(@job_posting)}

■ 근무시간
#{get_days_text(@job_posting)} #{get_hours_text(@job_posting)}

■ 급여
#{get_pay_text(@job_posting)}

아래 버튼을 눌러 지원하거나 일자리 정보를 자세히 확인해 보세요!"
  end

end