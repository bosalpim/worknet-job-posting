class Notification::Factory::NewJobNotification < Notification::Factory::NotificationFactoryClass
  NewJobPostingUsersService = Notification::SearchUser::NewJobPostingUsersService
  def initialize(job_posting_id)
    super(MessageTemplateName::NEW_JOB_POSTING)
    job_posting = JobPosting.find(job_posting_id)
    @job_posting = job_posting
    @list = NewJobPostingUsersService.call(job_posting)
    create_message
  end
  def create_message
    # 향후 작업
  end
end