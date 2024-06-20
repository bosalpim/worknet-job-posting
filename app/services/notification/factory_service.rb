class Notification::FactoryService
  # @param template_id : 메세지 Template
  # @params params : 각 template에 사용되는 변수
  include AlimtalkMessage
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
    when MessageTemplateName::TARGET_USER_RESIDENT_POSTING
      return Notification::Factory::TargetUserResidentJobPostingService.new(params)
    when MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE_ONE_DAY_AGO
      return Notification::Factory::NotifyCloseFreeJobPosting.call_1day_ago
    when MessageTemplateName::NOTIFY_FREE_JOB_POSTING_CLOSE
      return Notification::Factory::NotifyCloseFreeJobPosting.call_close(params[:job_postings])
    when MessageTemplateName::JOB_APPLICATION
      return Notification::Factory::NewJobApplication.new(params[:id] || params["id"])
    when MessageTemplateName::CONTACT_MESSAGE
      return Notification::Factory::NewContactMessage.new(params[:id] || params["id"])
    when MessageTemplateName::PROPOSAL_ACCEPT
      return Notification::Factory::ProposalAccepted.new(params)
    when MessageTemplateName::PROPOSAL_RESIDENT
      return Notification::Factory::ProposalResident.new(params)
    when MessageTemplateName::CALL_SAVED_JOB_CAREGIVER
      return Notification::Factory::UserSavedJobPosting.new(params)
    when MessageTemplateName::CONFIRM_CAREER_CERTIFICATION
      return Notification::Factory::ConfirmCareerCertification.new(params[:id])
    when MessageTemplateName::BUSINESS_JOB_POSTING_COMPLETE
      return Notification::Factory::BusinessJobPostingComplete.new(params[:job_posting_id])
    when MessageTemplateName::SMART_MEMO
      return Notification::Factory::SmartMemo.new(params)
    when MessageTemplateName::TARGET_JOB_POSTING_PERFORMANCE
      return Notification::Factory::TargetJobPostingPerformance.new
    when MessageTemplateName::TARGET_JOB_POSTING_AD
      return Notification::Factory::TargetJobPostingAd.new(params)
    when MessageTemplateName::NONE_LTC_REQUEST
      return Notification::Factory::NewNoneLtcRequest.new(params)
    when MessageTemplateName::JOB_SUPPORT_REQUEST_AGREEMENT
      return Notification::Factory::JobSupportRequestAgreement.new(params)
    when MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY
      return Notification::Factory::TargetJobPostingAdApply.new(params)
    when MessageTemplates[MessageNames::TARGET_USER_JOB_POSTING]
      return Notification::Factory::TargetUserJobPostingService.new(params)
    when MessageTemplateName::CAREER_CERTIFICATION_V3
      return Notification::Factory::EmploymentConfirmationService.new(params)
    when MessageTemplates[MessageNames::TARGET_JOB_POSTING_AD_2]
      return Notification::Factory::TargetJobPostingAdAfterPostingDaysService.new(params)
    else
      p "no template found : #{template_id}"
      return []
    end
  end

end