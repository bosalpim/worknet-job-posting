class Notification::Factory::CbtDraft < Notification::Factory::MessageFactoryClass
  include RatioChopper
  def initialize
    super(MessageTemplateName::CBT_DRAFT)
    @list = RatioChopper.chop_list(SearchNewCbtDraftUsersService.call(3), 30) # Todo 점진적 배포 대상으로, 30% -> 50% -> 100% 대상에게 발송 예정
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
      @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, "AI", user.phone_number, params, user.public_id))
    end
  end

end