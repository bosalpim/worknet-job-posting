class Notification::Factory::TargetJobPostingPerformance < Notification::Factory::NotificationFactoryClass
  def initialize
    super(MessageTemplateName::TARGET_JOB_POSTING_PERFORMANCE)
    @list = GetLocalAdsUsersService.call
    create_message
  end

  def create_message
    @list.each do |job_posting|
      Jets.logger.info "-------------- INFO START --------------\n"
      Jets.logger.info "케어파트너 대상 공고 : #{job_posting.public_id}\n"


      params = {
        target_public_id: job_posting.public_id,
        title: job_posting.title
      }
      @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, job_posting.manager_phone_number, params, job_posting.public_id, "AI"))
      Jets.logger.info "-------------- INFO END --------------\n"
    end
  end
end