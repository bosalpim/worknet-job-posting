class Notification::Factory::TargetJobPostingAdAfterPostingDaysService < Notification::Factory::NotificationFactoryClass
  include JobPostingsHelper
  include AlimtalkMessage

  JobPostingTargetUserService = Notification::Factory::SearchTarget::JobPostingTargetUserService
  def initialize(params)
    super(MessageTemplates::TEMPLATES[MessageNames::TARGET_JOB_POSTING_AD_2])
    @list = TargetAdAfterPostingSubjectFilterService.call
    create_message
  end

  def create_message
    @list.each do |job_posting|
      Jets.logger.info "-------------- INFO START --------------\n"
      Jets.logger.info "케어파트너 대상 공고 : #{job_posting.public_id}\n"

      utm = "utm_source=message&utm_medium=arlimtalk&utm_campaign=#{@message_template_id}"
      link = "#{Main::Application::BUSINESS_URL}/recruitment_management/#{job_posting.public_id}/target-notification?#{utm}"
      title = job_posting.title
      address = get_dong_name_by_address(job_posting.address)
      count = JobPostingTargetUserService.call(job_posting.lat, job_posting.lng).length

      if count > 5 and job_posting.scraped_worknet_job_posting_id.nil?
        Jets.logger.info "대상자 100명 이상이기에 발송\n"

        params = {
          job_posting_public_id: job_posting.public_id,
          link: link,
          title: title,
          address: address,
          count: count
        }

        @bizm_post_pay_list.push(BizmPostPayMessage.new(@message_template_id, job_posting.manager_phone_number, params, job_posting.public_id, "AI"))
      else
        Jets.logger.info "대상자 100명 이상이 아니기에 취소\n"
      end
      Jets.logger.info "-------------- INFO END --------------\n"
    end

  end
end