class Notification::FactoryService
  # @param template_id : 메세지 Template
  # @params params : 각 template에 사용되는 변수
  def self.create(template_id, params)
    case template_id
    when MessageTemplateName::CALL_SAVED_JOB_POSTING_V2
      return Notification::Factory::CallSavedJobPostingV2.new
    when MessageTemplateName::CBT_DRAFT
      return Notification::Factory::CbtDraft.new
    when MessageTemplateName::CAREPARTNER_PRESENT
      return Notification::Factory::CarepartnerNewDraft.new
    when MessageTemplateName::ACCUMULATED_DRAFT
      return Notification::Factory::AccumulatedDraft.new
    when MessageTemplate::ACCUMULATED_PREPARATIVE
      return Notification::Factory::AccumulatedPreparativeCbt.new
    else
      puts "no template found"
      return []
    end
  end
end