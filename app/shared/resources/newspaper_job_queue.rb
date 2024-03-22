# frozen_string_literal: true

class NewspaperJobQueue < Jets::Stack
  sqs_queue(:newspaper_job_queue)
end
