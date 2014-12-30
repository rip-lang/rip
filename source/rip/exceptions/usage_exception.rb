module Rip::Exceptions
  class UsageException < Base
    status_code 14

    def dump
      message
    end
  end
end
