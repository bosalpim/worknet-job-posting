class Notification::Factory::JobPostingTargetMessageService < Notification::Factory::NewJobNotification
  JobPostingTargetUserService = Notification::Factory::SearchTarget::JobPostingTargetUserService
  def set_list
    @list = JobPostingTargetUserService.call(@job_posting.lat, @job_posting.lng, @params[:distance], @params[:gender])
  end

end