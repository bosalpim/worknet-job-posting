class Notification::Factory::CbtDraft < Notification::Factory::NotificationFactoryClass
  include RatioChopper
  def initialize
    super(MessageTemplateName::CBT_DRAFT)
    @list = SearchNewCbtDraftUsersService.call(3)
    create_message
  end

  def create_message
    @list.each do |user|
      Jets.logger.info "-------------- INFO START --------------\n"
      Jets.logger.info "Cbt 대상 User : #{user.public_id}\n"
      Jets.logger.info "-------------- INFO END --------------\n"
      params = {
        target_public_id: user.public_id,
        name: user.name
      }
      @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, user.phone_number, params, user.public_id, "AI"))
    end
  end

end