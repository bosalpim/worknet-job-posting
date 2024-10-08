class Notification::Factory::CarepartnerNewDraft < Notification::Factory::NotificationFactoryClass
  include AlimtalkMessage
  def initialize
    super(MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM])
    @list = SearchNewCarepartnerDraftUsersService.call(1)
    create_message
  end

  def create_message
    @list.each do |user|
      Jets.logger.info "-------------- INFO START --------------\n"
      Jets.logger.info "케어파트너 대상 User : #{user.public_id}\n"
      Jets.logger.info "-------------- INFO END --------------\n"
      params = {
        target_public_id: user.public_id,
        name: user.name
      }
      @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, user.phone_number, params, user.public_id, "AI"))
    end
  end

end