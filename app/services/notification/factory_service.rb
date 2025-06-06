class Notification::FactoryService
  # @param template_id : 메세지 Template
  # @params params : 각 template에 사용되는 변수
  include AlimtalkMessage
  def self.create(template_id, params)
    case template_id
    when MessageTemplateName::CALL_SAVED_JOB_POSTING_V2
      return Notification::Factory::CallSavedJobPostingV2.new
    when MessageTemplates[MessageNames::CBT_DRAFT_CRM]
      return Notification::Factory::CbtDraft.new
    when MessageTemplates[MessageNames::ONE_DAY_CAREPARTNER_CERTFICATION_LEAK_CRM]
      return Notification::Factory::CarepartnerNewDraft.new
    when MessageTemplateName::ACCUMULATED_DRAFT
      return Notification::Factory::AccumulatedDraft.new
    when MessageTemplateName::ACCUMULATED_PREPARATIVE
      return Notification::Factory::AccumulatedPreparativeCbt.new
    when MessageTemplates[MessageNames::TARGET_USER_RESIDENT_JOB_POSTING]
      return Notification::Factory::TargetUserResidentJobPostingService.new(params)
    when MessageTemplateName::CLOSE_JOB_POSTING_REMIND_1DAY_AGO
      return Notification::Factory::NotifyCloseFreeJobPosting.call_1day_ago
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
    when MessageTemplateName::NONE_LTC_REQUEST
      return Notification::Factory::NewNoneLtcRequest.new(params)
    when MessageTemplateName::JOB_SUPPORT_REQUEST_AGREEMENT
      return Notification::Factory::JobSupportRequestAgreement.new(params)
    when MessageTemplateName::TARGET_JOB_POSTING_AD_APPLY
      return Notification::Factory::TargetJobPostingAdApply.new(params)
    when MessageTemplates[MessageNames::TARGET_USER_JOB_POSTING]
      return Notification::Factory::TargetUserJobPostingService.new(params)
    when MessageNames::PLUSTALK
      return Notification::Factory::PlustalkService.new(params)
    when MessageTemplateName::CAREER_CERTIFICATION_V3
      return Notification::Factory::EmploymentConfirmationService.new(params)
    when MessageTemplates[MessageNames::TARGET_JOB_BUSINESS_FREE_TRIALS]
      return Notification::Factory::TargetJobBusinessFreeTrialsService.new(params)
    when MessageTemplate[MessageNames::ACADEMY_LEADERBOARD]
      return Notification::Factory::AcademyLeaderboardPushService.new(params)
    else
      p "no template found : #{template_id}"
      return []
    end
  end

end