class Notification::Factory::TargetJobPostingAd < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  def initialize(params)
    super(MessageTemplateName::TARGET_JOB_POSTING_AD)
    @job_posting = JobPosting.find(params[:job_posting_id])
    @business = @job_posting.business
    @client = @business.clients.first
    @count = params[:count]
    create_message
  end

  def create_message
    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    link = "#{Main::Application::BUSINESS_URL}/recruitment_management/#{@job_posting.public_id}/local-ads?#{utm}"

    params = {
      link: link,
      target_public_id: @client.public_id,
      job_posting_id: @job_posting.id,
      title: @job_posting.title,
      address: get_dong_name_by_address(@job_posting.address),
      count: @count,
      center_name: @business.name,
    }

    @bizm_post_pay_list.push(
      BizmPostPayMessage.new(
        @message_template_id,
        @job_posting.manager_phone_number,
        params,
        @client.public_id, 'AI'
      ))

  end
end