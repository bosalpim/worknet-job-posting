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
    template_id = KakaoTemplate::PROPOSAL_ACCEPTED
    link = build_short_url(proposal)

    response = KakaoNotificationService.call(
      template_id: template_id,
      phone: Jets.env == "production" ? user.phone_number : '01097912095',
      template_params: {
        business_name: business.name,
        job_posting_title: job_posting.title,
        user_name: user.name,
        age: user.birth_year ? "#{calculate_korean_age(user.birth_year)}세" : "정보없음",
        address: user.address,
        career: user.career,
        self_introduce: user.self_introduce,
        proposal_id: proposal.id,
        auth_token: proposal.auth_token,
        link: link,
      }
    )

    send_type = KakaoNotificationResult::PROPOSAL_ACCEPTED
    send_id = proposal.id
    save_kakao_notification(response, send_type, send_id, template_id)
    response
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

  def save_kakao_notification(response, send_type, send_id, template_id)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reason = ""

    if response.dig("code") == "success"
      if response.dig("message") == "K000"
        success_count += 1
      else
        tms_success_count += 1
      end
    else
      fail_count += 1
      fail_reason = response.dig("originMessage")
    end

    KakaoNotificationResult.create!(
      send_type: send_type,
      send_id: send_id,
      template_id: template_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reason
    )
  end

  def build_short_url(proposal)
    short_url = ShortUrl.build(
      "https://business.carepartner.kr/proposals/#{proposal.id}?auth_token=#{proposal.auth_token}&utm_source=message&utm_medium=arlimtalk&utm_campaign=proposal_accepted",
      "https://business.carepartner.kr"
    )
    short_url.url
  end

  def build_proposal(proposal_id)
    Proposal.find(proposal_id)
  end
end