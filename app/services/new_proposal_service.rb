class NewProposalService
  include Translation
  include JobPostingsHelper

  attr_reader :proposal

  def initialize(proposal_id)
    @proposal = build_proposal(proposal_id)
  end

  def call
    user = proposal.user
    business = proposal.business
    job_posting = JobPosting.find_by(public_id: proposal.job_posting_id)

    KakaoNotificationService.call(
      template_id: MessageTemplate::PROPOSAL_RESPONSE_EDIT,
      message_type: 'AT',
      phone: user.phone_number,
      template_params: {
        user_name: user.name,
        business_name: business.name,
        distance: I18n.t("activerecord.attributes.user.preferred_distance.#{user.preferred_distance}"),
        address: job_posting.address,
        work_type_ko: translate_type('job_posting', job_posting, :work_type),
        pay_text: get_pay_text(job_posting),
        business_vn: job_posting.vn,
        job_posting_title: job_posting.title,
        job_posting_public_id: job_posting.public_id,
        target_public_id: user.public_id,
        employee_id: user.public_id,
      },
    )
  end

  private

  def build_proposal(proposal_id)
    Proposal.find(proposal_id)
  end
end