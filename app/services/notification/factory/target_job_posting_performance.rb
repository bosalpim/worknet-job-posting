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

      count = DispatchedNotification.where(notification_relate_instance_types_id: 3,
                                           notification_relate_instance_id: job_posting.id)
                                    .where.not(confirmed: nil)
                                    .count
      if count > 0
        Jets.logger.info "수신 대상자 : #{count}명\n"
        params = {
          target_public_id: job_posting.public_id,
          title: job_posting.title,
          count: count
        }
        @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, job_posting.manager_phone_number, params, job_posting.public_id, "AI"))
      else
        Jets.logger.info "수신 대상자 없음 종료\n"
      end
      Jets.logger.info "-------------- INFO END --------------\n"
    end
  end
end