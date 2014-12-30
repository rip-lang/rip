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
      _context = context.nested_context

      _parameters = parameters.map do |parameter|
        parameter.interpret(_context)
      end

      Rip::Core::Overload.new(_parameters, body)
    end

    def to_debug(level = 0)
      parameters_debug_inner = parameters.inject([]) do |reply, parameter|
        reply + parameter.to_debug(level + 2)
      end

      parameters_debug = [ [ level + 1, 'parameters = [' ] ] +
        parameters_debug_inner +
        [ [ level + 1, ']' ] ]

      body_debug = [ [ level + 1, 'body = [' ] ] +
        body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      [
        [ level, "#{super.last.last}" ]
      ] + parameters_debug + body_debug
    end

    # convert list of overloads, some which may have optional paramters, into list of overloads with no optional parameters
    def self.expand(overloads)
      overloads.map do |overload|
        required_parameters, optional_parameters = overload.parameters.partition do |parameter|
          parameter.required?
        end

        reply = []

        synthetic_location = overload.location

        optional_parameters.inject(required_parameters) do |memo, parameter|
          synthetic_arguments = memo.map do |p|
            Rip::Nodes::Reference.new(parameter.location, p.name)
          end + [ parameter.default_expression ]

          synthetic_body = Rip::Nodes::BlockBody.new(synthetic_location, [
            Rip::Nodes::Invocation.new(synthetic_location, Rip::Nodes::Reference.new(synthetic_location, 'self'), synthetic_arguments)
          ])

          reply << Rip::Nodes::Overload.new(overload.location, memo, synthetic_body)

          [ *memo, Rip::Nodes::Parameter.new(parameter.location, parameter.name, parameter.type) ]
        end

        final_parameters = required_parameters + optional_parameters.map do |parameter|
          Rip::Nodes::Parameter.new(parameter.location, parameter.name, parameter.type)
        end

        [ *reply, Rip::Nodes::Overload.new(synthetic_location, final_parameters, overload.body) ]
      end.flatten
    end
  end
end
