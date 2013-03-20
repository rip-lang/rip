module Rip::Nodes
  class String < List
    def initialize(location, phrase)
      super(location, phrase.split('').map(&:to_sym))
    end
  end
end
