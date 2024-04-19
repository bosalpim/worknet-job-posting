class Notification::Factory::ProposalResident < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include TranslationHelper
  include DayHelper
  include DispatchedNotificationsHelper

  DispatchedNotificationService = Notification::Factory::DispatchedNotifications::Service

  def initialize(params)
    super(MessageTemplateName::PROPOSAL_RESIDENT)
    @job_posting = JobPosting.find_by(public_id: params[:job_posting_id])
    @receive_vn = params[:receive_vn]
    @base_url = "#{Main::Application::CAREPARTNER_URL}jobs/#{@job_posting.public_id}"
    @deeplink_scheme = Main::Application::DEEP_LINK_SCHEME
    @list = [User.find(params[:user_id])]
    @dispatched_notifications_service = DispatchedNotificationService.call(@message_template_id, "target_message", @job_posting.id, "yobosa")
    create_message
  end

  def create_message
    @list.each do |user|
      unless user.is_a?(User)
        next
      end

      message = create_arlimtalk(
        user
      )

      @bizm_post_pay_list.push(message) if message.present?
    end
  end

  def create_arlimtalk(user)
    unless user.is_a?(User)
      return nil
    end

    dispatched_notification_param = create_dispatched_notification_params(@message_template_id, "target_message", @job_posting.id, "yobosa", user.id, "job_detail")


    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    view_link = "#{@base_url}?lat=#{user.lat}&lng=#{user.lng}&referral=#{@message_template_id}&#{utm}" + dispatched_notification_param + "&check_proposed_content=true"
    tel_link = "tel://#{@receive_vn}"

    BizmPostPayMessage.new(
      @message_template_id,
      user.phone_number,
      {
        title: @job_posting.title,
        message: generate_message_content,
        view_link: view_link,
        tel_link: tel_link,
        job_posting_id: @job_posting.id,
        job_posting_public_id: @job_posting.public_id,
        business_name: @job_posting.business.name,
        job_posting_type: @job_posting.work_type,
      },
      user.public_id,
      "AI"
    )
  end
  def generate_message_content
    "#{@job_posting.business.name}에서 입주요양 일자리를 제안했어요.

■ 급여 : #{get_pay_text(@job_posting)}

■ 어르신 정보 : #{create_customer_info(@job_posting.job_posting_customer)}

■ 근무 장소 : #{@job_posting.address}

■ 근무 요일(입주) : 주 #{@job_posting.working_days.count}일 근무 #{vacation_day_resident(@job_posting)}

👇'제안 내용 확인하기' 버튼을 누르고 자세한 정보를 확인하세요👇

이 메세지는 일자리알림을 신청한 분에게만 발송됩니다"
  end
end
