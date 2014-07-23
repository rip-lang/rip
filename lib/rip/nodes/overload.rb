module Rip::Nodes
  class Overload < Rip::Nodes::Base
    attr_reader :parameters
    attr_reader :body

    def initialize(location, parameters, body)
      super(location)

      @parameters = parameters
      @body = body
    end

    def ==(other)
      super &&
        (parameters == other.parameters) &&
        (body == other.body)
    end

    def interpret(context)
      Rip::Core::Overload.new(parameters, body)
    end

    # convert list of overloads, some which may have optional paramters, into list of overloads with no optional parameters
    def self.expand(overloads)
      overloads.map do |overload|
        required_parameters, optional_parameters = overload.parameters.partition do |parameter|
          parameter.required?
        end

        reply = []

        optional_parameters.inject(required_parameters) do |memo, parameter|
          synthetic_arguments = memo.map do |p|
            Rip::Nodes::Reference.new(parameter.location, p.name)
          end + [ parameter.default_expression ]

          synthetic_body = [
            Rip::Nodes::Invocation.new(overload.location, Rip::Nodes::Reference.new(overload.location, 'self'), synthetic_arguments)
          ]

          reply << Rip::Nodes::Overload.new(overload.location, memo, synthetic_body)

          [ *memo, Rip::Nodes::Parameter.new(parameter.location, parameter.name, parameter.raw_type) ]
        end

        final_parameters = required_parameters + optional_parameters.map do |parameter|
          Rip::Nodes::Parameter.new(parameter.location, parameter.name, parameter.raw_type)
        end

        [ *reply, Rip::Nodes::Overload.new(overload.location, final_parameters, overload.body) ]
      end.flatten
    end
  end
end
