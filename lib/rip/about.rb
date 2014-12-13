module Rip
  module About
    extend Comparable

    SIGNATURE = [0, 1, 0]

    def self.<=>(other)
      other = other.split('.').map(&:to_i) if other.respond_to? :split
      SIGNATURE <=> Array(other)
    end

    def self.summary(verbose = false)
      reply = SIGNATURE.join('.')
      verbose ? "Rip version #{reply}" : reply
    end
  end
end
