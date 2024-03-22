# frozen_string_literal: true

class Newspaper < Jets::Stack
  sqs_queue(:newspaper_job_queue)
end
