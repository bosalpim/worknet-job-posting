class Notification::Factory::CbtDraft < Notification::Factory::NotificationFactoryClass
  include RatioChopper
  include AlimtalkMessage
  def initialize
    super(MessageTemplates[MessageNames::CBT_DRAFT_CRM])
    @list = User.where(phone_number: '01094659404')
    # @list = SearchNewCbtDraftUsersService.call(3)
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