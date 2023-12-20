class Notification::Factory::BusinessJobPostingComplete  < Notification::Factory::NotificationFactoryClass
  def initialize(job_posting_id)
    super(MessageTemplateName::BUSINESS_JOB_POSTING_COMPLETE)
    @job_posting = JobPosting.find_by(id: job_posting_id)
    @business = @job_posting.business
    @list = @business.clients
    create_message
  end

  def create_message
    @list.each do |client|
      Jets.logger.info "-------------- INFO START --------------\n"
      Jets.logger.info "기관 : #{client.public_id}\n"
      Jets.logger.info "-------------- INFO END --------------\n"

      params = {
        target_public_id: client.public_id,
        job_posting_title: @job_posting.title,
        job_posting_public_id: @job_posting.public_id
      }

      @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, client.phone_number, params, client.public_id, "AI"))
    end
  end
end