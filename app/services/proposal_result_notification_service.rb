class ProposalResultNotificationService
  include JobPostingsHelper

  attr_reader :proposal

  def initialize(proposal_id)
    @proposal = build_proposal(proposal_id)
  end

  def accepted_call
    user = proposal.user
    business = proposal.business
    job_posting = JobPosting.find_by(public_id: proposal.job_posting_id)

    KakaoNotificationService.call(
      template_id: KakaoTemplate::PROPOSAL_ACCEPTED,
      phone: Jets.env == "production" ? user.phone_number : '01097912095',
      template_params: {
        business_name: business.name,
        job_posting_title: job_posting.title,
        user_name: user.name,
        age: user.birth_year ? "#{calculate_korean_age(user.birth_year)}세" : "정보없음",
        address: user.address,
        career: user.career,
        self_introduce: user.self_introduce,
        proposal_id: proposal.id
      }
    )
  end

  def rejected_call
    user = proposal.user
    business = proposal.business
    job_posting = JobPosting.find_by(public_id: proposal.job_posting_id)

    KakaoNotificationService.call(
      template_id: KakaoTemplate::PROPOSAL_REJECTED,
      phone: Jets.env == "production" ? user.phone_number : '01097912095',
      template_params: {
        business_name: business.name,
        job_posting_title: job_posting.title,
        user_name: user.name,
        age: user.birth_year ? "#{calculate_korean_age(user.birth_year)}세" : "정보없음",
        address: user.address,
        career: user.career,
        self_introduce: user.self_introduce,
        proposal_id: proposal.id
      }
    )
  end

  private

  def build_proposal(proposal_id)
    Proposal.find(proposal_id)
  end
end