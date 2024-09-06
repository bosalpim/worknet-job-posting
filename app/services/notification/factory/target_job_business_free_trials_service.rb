
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
              .where("preferred_work_types ?| array[:work_types]", work_types: [@job_posting.work_type])
              .where.not(phone_number: nil)
              .within_radius(
                radius,
                @job_posting.lat,
                @job_posting.lng
              ).limit(200) + User.where(phone_number: ['01094659404', '01029465752']) # 하민, 준혁은 계속 받도록 처리
    create_message
  end

  def save_result
    super
    SlackWebhookService.call(:business_free_trial, {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: '타켓 지역 워크넷 신규 일자리 알림 발송 완료'
          }
        },
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: "공고 publicId : #{@job_posting.public_id}"
          }
        },
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: "#{@list.count} 명 발송"
          }
        }
      ]
    })
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
    is_under_10000 = ([@job_posting.min_wage.nil? ? 0 : @job_posting.min_wage , @job_posting.max_wage.nil? ? 0 : @job_posting.max_wage].max) < 10000
    pay_text = @job_posting.scraped_worknet_job_posting&.info&.dig('pay_text').nil? || is_under_10000 ? "협의 후 결정" : @job_posting.scraped_worknet_job_posting&.info&.dig('pay_text')
    grade_info = translate_type('job_posting_customer', @job_posting, 'grade') || '등급 정보 없음'
    gender_info = translate_type('job_posting_customer', @job_posting, 'gender') || '성별 정보 없음'
    "#{@job_posting.title}

■ 급여 : #{pay_text}

■ 근무 장소 : #{@job_posting.address}

■ 근무 시간 : #{@job_posting.scraped_worknet_job_posting&.info&.dig('origin_hours_text') || '시간정보 없음'}

■ 어르신 정보 : #{grade_info + ', ' + gender_info }

이 메세지는 일자리알림을 신청한 분에게만 발송돼요

👇'일자리 확인하기' 버튼을 누르고 자세한 정보를 확인하세요👇"
  end
end