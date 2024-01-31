# frozen_string_literal: true

module NotificationType
  RELATE_TYPE_JOB_POSTING = 1
  TYPE_STARTED = 'started'
  TYPE_SUCCEDED = 'succeded'
  TYPE_RESERVED = 'reserved'
  TYPE_ENDED = 'ended'
  TYPE_CANCELED = 'canceled'

  class Base
    def send
      raise 'send not implemented'
    end
  end

end
