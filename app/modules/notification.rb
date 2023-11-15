# frozen_string_literal: true

module Notification
  class Base
    def send
      raise 'send not implemented'
    end
  end

end
