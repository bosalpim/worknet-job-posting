class Notification::Factory::TargetUserResidentJobPostingService < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include TranslationHelper
  include DayHelper

  def initialize(params)
    super(MessageTemplateName::TARGET_USER_RESIDENT_POSTING)
    @job_posting = JobPosting.find(params[:job_posting_id])
    paid_job_posting = PaidJobPostingFeature.find_by_job_posting_id(params[:job_posting_id])
    @is_free = paid_job_posting.nil? ? true : false
    @base_url = "#{Main::Application::CAREPARTNER_URL}jobs/#{@job_posting.public_id}"
    @deeplink_scheme = Main::Application::DEEP_LINK_SCHEME
    radius = params[:radius].nil? ? 7000 : params[:radius]
    min_radius = params[:min_radius].nil? ? nil : params[:min_radius]
    @list = User
              .receive_job_notifications
              .selected_resident
              .within_radius(
                radius,
                @job_posting.lat,
                @job_posting.lng,
                min_radius
                ).where.not(phone_number: nil)
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

    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    view_link = "#{@base_url}?lat=#{user.lat}&lng=#{user.lng}&referral=target_notification&#{utm}"
    application_link = "#{@base_url}/application?referral=target_notification&#{utm}"

    BizmPostPayMessage.new(
      @message_template_id,
      user.phone_number,
      {
        title: @job_posting.title,
        message: generate_message_content,
        view_link: view_link,
        application_link: application_link,
        job_posting_id: @job_posting.id,
        job_posting_public_id: @job_posting.public_id,
        business_name: @job_posting.business.name,
        job_posting_type: @job_posting.work_type,
        is_free: @is_free
      },
      user.public_id,
      "AI"
    )
  end
  def generate_message_content
    "#{@job_posting.title}

■ 급여 : #{get_pay_text(@job_posting)}

■ 어르신 정보 : #{create_customer_info(@job_posting.job_posting_customer)}

■ 근무 장소 : #{@job_posting.address}

■ 근무 요일(입주) : 주 #{@job_posting.working_days.count}일 근무#{vacation_day_resident(@job_posting)}

이 메세지는 일자리알림을 신청한 분에게만 발송돼요

👇'일자리 확인하기' 버튼을 누르고 자세한 정보를 확인하세요👇"
  end
end
