class Notification::Factory::NotifyCloseFreeJobPosting < Notification::Factory::NotificationFactoryClass
  include ApplicationHelper
  include TranslationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper

  def self.call_1day_ago
    new(true)
  end

  private
  def initialize(one_day_ago)
    super(MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO)
    init_close_1day_ago
  end

  def init_close_1day_ago
    today_afternoon_4 = DateTime.now.beginning_of_day.change(hour: 4, min: 0, sec: 0)
    next_day_afternoon_4 = DateTime.now.next_day.beginning_of_day.change(hour: 4, min: 0, sec: 0)

    job_postings = JobPosting
                     .where(status: 'init')
                     .where(scraped_worknet_job_posting_id: nil)
                     .where(applying_due_date: 'three_days')
                     .where(closing_at: today_afternoon_4...next_day_afternoon_4)

    Jets.logger.info "금일, 내일 완전 종료 대상 : #{job_postings.pluck(:public_id)}"

    @list = job_postings
    create_message
  end

  def create_message
    @list.each do |job_posting|
      create_bizm_post_pay_message(job_posting)
    end
  end

  def create_bizm_post_pay_message(job_posting)
    suffix = '/recruitment_management'
    link = if Jets.env.production?
             "https://business.carepartner.kr#{suffix}"
           elsif Jets.env.staging?
             "https://staging-business.vercel.app#{suffix}"
           else
             "https://localhost:3001#{suffix}"
           end
    title = job_posting.title
    business_client = BusinessClient.find_by(business_id: job_posting.business_id)
    client = Client.find_by(id: business_client.client_id)
    params = {
      job_posting_public_id: job_posting.public_id,
      title: title,
      link: link,
      target_public_id: client.public_id
    }

    reserved_dt = DateTime.now.strftime("%Y%m%d") + "100000"
    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, client.phone_number, params, client.public_id, 'AI', reserved_dt))
  end
end