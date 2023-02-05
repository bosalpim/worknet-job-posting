class NewProposalNotificationService
  include Translation
  include JobPostingsHelper

  def initialize(current_client_id, target_user_id, job_posting_id, proposal_id)
    @current_client = build_client(current_client_id)
    @target_user = build_user(target_user_id)
    @job_posting = build_job_posting(job_posting_id)
    @proposal = build_proposal(proposal_id)
    @business = @job_posting.business
  end

  def call
    work_type_ko = translate_type('job_posting', job_posting, :work_type)

    response = KakaoNotificationService.call(
      template_id: KakaoTemplate::PROPOSAL,
      phone: Jets.env == "production" ? target_user.phone_number : current_client.phone_number,
      template_params: {
        user_name: target_user.name,
        business_name: business.name,
        business_vn: job_posting.vn || business.phone_number,
        work_type_ko: work_type_ko,
        address: job_posting.address,
        distance: target_user.distance_from_ko(job_posting),
        pay_text: get_pay_text(job_posting),
        job_posting_public_id: job_posting.public_id
      }
    )
    update_proposal(response)
  end

  private

  attr_reader :current_client, :business, :target_user, :job_posting, :proposal

  def update_proposal(response)
    if response.present? && response[0].present?
      code = response[0].dig("code")
      result_code = response[0].dig("message")&.split(":")&.first
      if code == "success"
        proposal.update(kakao_notification_success_yes: true)
      else
        rollback_proposal_ticket(proposal)
        case result_code
        when "K101", "M103", "M104" # 수신이 불가능한 사용자
          user.unacceptable!
        when "K102", "M102" # 전화번호 오류
          user.phone_number_error!
        when "M105" # 수신자 단말기 전원 꺼짐
          user.sleep!
        else
          # Sentry.capture_message("카카오 알림톡 발송 실패:\nproposalId: #{proposal.id}\nresponse: " + JSON.dump(response[0]))
        end
      end
      result_code
    else
      -2
    end
  end

  def rollback_proposal_ticket(proposal)
    if proposal.paid?
      business_usable_count = business.proposal_usable_count
      business.update!(proposal_usable_count: business_usable_count + 1)
    else
      job_usable_count = job_posting.proposal_usable_count
      job_posting.update!(proposal_usable_count: job_usable_count + 1)
    end
    proposal.destroy
  end

  def build_client(current_client_id)
    nil # Client.find(current_client_id)
  end

  def build_user(user_id)
    User.find(user_id)
  end

  def build_job_posting(job_posting_id)
    JobPosting.find(job_posting_id)
  end

  def build_proposal(proposal_id)
    # Proposal.find(proposal_id)
    nil
  end
end