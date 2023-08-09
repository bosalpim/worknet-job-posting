# frozen_string_literal: true

class NotifyMatchedUserService

  def self.call(event)
    new(event).call
  end

  def initialize(event)
    @messages = event[:messages] || []
  end

  def call
    success_count = 0
    fail_count = 0
    fail_reasons = []
    template_id = KakaoTemplate::CANDIDATE_RECOMMENDATION
    @messages.each do |message|
      response = KakaoNotificationService.call(
        template_id: template_id,
        phone: message[:phone],
        template_params: {
          target_public_id: message["clientPublicId"],
          job_posting_public_id: message["jobPostingPublicId"],
          job_posting_title: message["jobPostingTitle"],
          username: message["username"],
          center_name: message["centerName"],
          job_search_status: message["jobSearchStatus"],
          employee_id: message["userPublicId"],
          age: message["age"],
          resume_published_at: message["resumePublishedAt"],
          gender: message["gender"],
          career: message["career"],
          link: message["link"]
        },
        message_type: "AI"
      )

      if response.dig("code") == "success"
        success_count += 1
      else
        fail_count += 1
        fail_reasons.push(response.dig("originMessage")) if response.dig("message") != "K000"
      end

      KakaoNotificationResult.create!(
        send_type: "notify_matched_user",
        template_id: template_id,
        success_count: success_count,
        fail_count: fail_count,
        fail_reasons: fail_reasons.uniq.join(",")
      )

    end

  end
end
