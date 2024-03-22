# frozen_string_literal: true

class NewspaperStack < Jets::Stack
  sqs_queue(:newspaper_job_queue)
end
