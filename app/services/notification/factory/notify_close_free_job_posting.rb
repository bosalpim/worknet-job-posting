class Notification::Factory::NotifyCloseFreeJobPosting < Notification::Factory::NotificationFactoryClass
  include ApplicationHelper
  include TranslationHelper
  include JobPostingsHelper
  include KakaoNotificationLoggingHelper

  def self.call_1day_ago
    new(true, nil)
  end

  def self.call_close(job_postings)
    new(false, job_postings)
  end

  private
  def initialize(one_day_ago, job_postings)
    super(one_day_ago ? MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO : MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE)
    one_day_ago ? init_close_1day_ago : init_close(job_postings)
  end

  def init_close_1day_ago
    today_afternoon_4 = DateTime.now.beginning_of_day.change(hour: 16, min: 0, sec: 0)
    next_day_afternoon_4 = DateTime.now.next_day.beginning_of_day.change(hour: 16, min: 0, sec: 0)

    job_postings = JobPosting
                     .where(status: 'init')
                     .where(scraped_worknet_job_posting_id: nil)
                     .where(applying_due_date: 'three_days')
                     .where(closing_at: today_afternoon_4...next_day_afternoon_4)

    @list = job_postings
    create_message
  end

  def init_close(job_postings)
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
             "http://business.carepartner.kr#{suffix}"
           elsif Jets.env.staging?
             "http://staging-business.vercel.app#{suffix}"
           else
             "http://localhost:3001#{suffix}"
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

    @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, 'AI', client.phone_number, params, client.public_id))
  end
end