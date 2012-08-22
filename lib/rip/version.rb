module Rip
  module Version
    extend Comparable

    SIGNATURE = [0, 1, 0]

    def self.<=>(other)
      other = other.split('.').map(&:to_i) if other.respond_to? :split
      SIGNATURE <=> Array(other)
    end

    def self.to_s(verbose = false)
      reply = SIGNATURE.join('.')
      verbose ? "Rip version #{reply}" : reply
    end
  end
end
