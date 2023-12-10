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
    when MessageTemplateName::ACCUMULATED_PREPARATIVE
      return Notification::Factory::AccumulatedPreparativeCbt.new
    when MessageTemplateName::NEW_JOB_POSTING
      return Notification::Factory::NewJobNotification.new(params[:job_posting_id])
    when MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO
      return Notification::Factory::NotifyCloseFreeJobPosting.call_1day_ago
    when MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE
      return Notification::Factory::NotifyCloseFreeJobPosting.call_close(params[:job_postings])
    when MessageTemplateName::JOB_APPLICATION
      return Notification::Factory::NewJobApplication.new(params[:job_application_id])
    when MessageTemplateName::CONTACT_MESSAGE
      return Notification::Factory::NewContactMessage.new(params[:contact_message_id])
    when MessageTemplateName::CALL_INTERVIEW_ACCEPTED
      return Notification::Factory::ProposalAccepted.new(params)
    when MessageTemplateName::CALL_SAVED_JOB_CAREGIVER
      return Notification::Factory::UserSavedJobPosting.new(params)
    when MessageTemplateName::JOB_ADS_MESSAGE_FIRST
      return Notification::Factory::JobAdsFirstMessage.new(params[:job_posting_id])
    when MessageTemplateName::JOB_ADS_MESSAGE_SECOND
      return Notification::Factory::JobAdsSecondMessage.new(params[:job_posting_id])
    when MessageTemplateName::JOB_ADS_MESSAGE_THIRD
      return Notification::Factory::JobAdsThirdMessage.new(params[:job_posting_id])
    when MessageTemplateName::JOB_ADS_MESSAGE_RESERVE
      return Notification::Factory::JobAdsMessageReserve.new(params[:job_posting_id], params[:times], params[:scheduled_at_text])
    when MessageTemplateName::JOB_ADS_COMPLETED
      return Notification::Factory::JobAdsMessageReserve.new(params[:job_posting_id])
    else
      puts "no template found"
      return []
    end
  end
end