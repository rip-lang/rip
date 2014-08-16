require 'spec_helper'

describe 'System.Integer', :blur do
  after(:each) { assert_exit_status(0) }

  [
    [ :+, 2, 3, '5' ]
  ].each do |(operator, a, b, result)|
    describe ".#{operator}" do
      specify do
        write_file 'sample.rip', <<-RIP
result = System.Integer.#{operator}(#{a}, #{b})
System.IO.out(result)
        RIP

        run_simple 'rip execute sample.rip'

        expect(all_stdout).to eq("#{result}\n")
      end
    end

    describe ".@.#{operator}" do
      specify do
        write_file 'sample.rip', <<-RIP
System.IO.out(#{a} #{operator} #{b})
        RIP

        run_simple 'rip execute sample.rip'

        expect(all_stdout).to eq("#{result}\n")
      end
    end
  end
end
