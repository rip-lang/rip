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

    def to_s_prep_body
      _items = items.map(&:to_s).join(', ')
      super + [ "items = [ #{_items} ]" ]
    end

    define_class_instance('list') do |class_instance|
      class_instance['@']['reverse'] = Rip::Core::NativeLambda.new([]) do |this, context|
        this.class.new(this.items.reverse)
      end

      class_instance['@']['head'] = Rip::Core::DynamicProperty.new do |this|
        this['head_left']
      end

      class_instance['@']['head_left'] = Rip::Core::DynamicProperty.new do |this|
        this.items.first
      end

      class_instance['@']['head_right'] = Rip::Core::DynamicProperty.new do |this|
        this.items.last
      end

      class_instance['@']['tail'] = Rip::Core::DynamicProperty.new do |this|
        this['tail_left']
      end

      class_instance['@']['tail_left'] = Rip::Core::DynamicProperty.new do |this|
        new(this.items[1..(this.items.count - 1)] || [])
      end

      class_instance['@']['tail_right'] = Rip::Core::DynamicProperty.new do |this|
        new(this.items[0..-2].reverse)
      end

      def class_instance.to_s
        '#< System.List >'
      end
    end
  end
end
