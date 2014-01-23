module Rip::Core
  class List < Rip::Core::Base
    attr_reader :items

    def initialize(items = [])
      super()

      @items = items

      self['class'] = self.class.class_instance
    end

    def ==(other)
      (self['class'] == other['class']) &&
        (items == other.items)
    end

    def to_s
      _items = items.map(&:to_s)
      "[#{_items.join(', ')}]"
    end

    define_class_instance do |class_instance|
      class_instance['@']['reverse'] = Rip::Core::RubyLambda.new(Rip::Utilities::Keywords[:dash_rocket], []) do |this, context|
        new(this.items.reverse)
      end

      def class_instance.to_s
        'System.List'
      end
    end
  end
end
