class ApplicationJob < Jets::Job::Base
  # Adjust to increase the default timeout for all Job classes
  class_timeout 900
end
