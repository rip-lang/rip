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
      class_instance['@']['reverse'] = Rip::Core::DelayedProperty.new do |this|
        reverse_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          this = context['@']
          this.class.new(this.items.reverse)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ reverse_overload ])
      end

      class_instance['@']['length'] = Rip::Core::DynamicProperty.new do |this|
        Rip::Core::Integer.new(this.items.count)
      end

      class_instance['@']['head'] = Rip::Core::DynamicProperty.new do |this|
        this.items.first
      end

      class_instance['@']['tail'] = Rip::Core::DynamicProperty.new do |this|
        new(this.items[1..(this.items.count - 1)] || [])
      end

      class_instance['+'] = Rip::Core::DelayedProperty.new do |_|
        plus_overload = Rip::Core::NativeOverload.new([
          Rip::Nodes::Parameter.new(nil, 'a'),
          Rip::Nodes::Parameter.new(nil, 'b')
        ]) do |context|
          a = context['a']
          b = context['b']
          Rip::Core::List.new(a.items + b.items)
        end

        Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ plus_overload ])
      end

      class_instance['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          items = context['@'].items.map do |item|
            string = item['to_string'].call([]).characters.map(&:data).join('')

            item.is_a?(Rip::Core::String) ? string.inspect : string
          end

          _items = [ '[', items.join(', '), ']' ].reject(&:empty?)

          Rip::Core::String.from_native(_items.join(' '))
        end

        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_string_overload ])
      end

      def class_instance.to_s
        '#< System.List >'
      end
    end
  end
end
