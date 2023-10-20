class Notification::Factory::NewJobNotification < Notification::Factory::NotificationFactoryClass
  def initialize(job_posting_id)
    super(MessageTemplateName::NEW_JOB_POSTING)
    job_posting = JobPosting.find(job_posting_id)
    @job_posting = job_posting
    # @list = 메세지 발송대상 추출 서비스 별도 생성
    create_message
  end
  def create_message
    # 향후 작업
  end
end