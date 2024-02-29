class Notification::Factory::JobSupportRequestAgreement < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  def initialize(params)
    super(MessageTemplateName::TARGET_JOB_POSTING_AD)
    @job_posting = JobPosting.find(params[:job_posting_id])
    @business = @job_posting.business
    @user = User.find(params[:user_id])
    @client = @business.clients.first
    create_message
  end

  def create_message
    utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
    link = "#{Main::Application::CAREPARTNER_URL}users/agreed-to-job-support?centerName=#{@business.name}&jobPostingId=#{@job_posting.id}&#{utm}"

    params = {
      link: link,
      birth_year: @user.birth_year,
      employee_id: @client.public_id,
      job_posting_id: @job_posting.id,
      title: @job_posting.title,
      center_name: @business.name,
    }

    @bizm_post_pay_list.push(
      BizmPostPayMessage.new(
        @message_template_id,
        @user.phone_number,
        params,
        @user.public_id, 'AI'
      ))

  end
end