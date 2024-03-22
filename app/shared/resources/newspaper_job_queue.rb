# frozen_string_literal: true

class Newstest < Jets::Stack
  sqs_queue(:newspaper_job_queue)
end
