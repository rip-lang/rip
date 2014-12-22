require 'spec_helper'

describe 'System.Integer' do
  after(:each) { assert_exit_status(0) }

  [
    [ :+, 2, 3, '5' ]
  ].each do |(operator, a, b, result)|
    describe ".#{operator}" do
      specify do
        expect(<<-RIP).to output_as("#{result}\n")
          result = System.Integer.#{operator}(#{a}, #{b})
          System.IO.puts(result)
        RIP
      end
    end

    describe ".@.#{operator}" do
      specify do
        expect(<<-RIP).to output_as("#{result}\n")
          System.IO.puts(#{a} #{operator} #{b})
        RIP
      end
    end
  end
end
