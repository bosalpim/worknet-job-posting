
class Notification::Factory::TargetJobBusinessFreeTrialsService < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include TranslationHelper
  include DayHelper
  include AlimtalkMessage
  def initialize(params)
    super(MessageTemplates[MessageNames::TARGET_JOB_BUSINESS_FREE_TRIALS])
    @job_posting = JobPosting.find(params[:job_posting_id])
    @base_url = "#{Main::Application::CAREPARTNER_URL}jobs/#{@job_posting.public_id}"
    @deeplink_scheme = Main::Application::DEEP_LINK_SCHEME
    radius = params[:radius].nil? ? 3000 : params[:radius]
    @list = User
              .receive_job_notifications
              .within_radius(
                radius,
                @job_posting.lat,
                @job_posting.lng
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

    BizmPostPayMessage.new(
      @message_template_id,
      user.phone_number,
      {
        title: @job_posting.title,
        message: generate_message_content,
        view_link: view_link,
        job_posting_id: @job_posting.id,
        job_posting_public_id: @job_posting.public_id,
        business_name: @job_posting.business.name,
        job_posting_type: translate_type('job_posting', @job_posting, :work_type)
      },
      user.public_id,
      "AI"
    )
  end
  def generate_message_content
    grade_info = translate_type('job_posting_customer', @job_posting, 'grade') || '등급 정보 없음'
    gender_info = translate_type('job_posting_customer', @job_posting, 'gender') || '성별 정보 없음'
    "#{@job_posting.title}

■ 급여 : #{@job_posting.scraped_worknet_job_posting&.info&.dig('pay_text') || '급여정보 없음'}

■ 근무 장소 : #{@job_posting.address}

■ 근무 시간 : #{@job_posting.scraped_worknet_job_posting&.info&.dig('origin_hours_text') || '시간정보 없음'}

■ 어르신 정보 : #{grade_info + ', ' + gender_info || '성별 정보 없음' }

이 메세지는 일자리알림을 신청한 분에게만 발송돼요

👇'일자리 확인하기' 버튼을 누르고 자세한 정보를 확인하세요👇"
  end
end