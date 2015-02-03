require 'spec_helper'

describe 'System.Lambda' do
  after(:each) { assert_exit_status(0) }

  describe 'default parameter expansion' do
    it 'works with three arguments' do
      expect(<<-RIP).to output_as('15')
        foo = -> (a, b, c = 3) { a + b + c }
        System.IO.out(foo(4, 5, 6))
      RIP
    end

    it 'works with two arguments, immediately appled' do
      expect(<<-RIP).to output_as('12')
        foo = -> (a, b, c = 3) { a + b + c }
        System.IO.out(foo(4, 5))
      RIP
    end

    it 'works with two arguments, partially appled' do
      expect(<<-RIP).to output_as('12')
        foo = -> (a, b, c = 3) { a + b + c }
        foo4 = foo(4)
        System.IO.out(foo4(5))
      RIP
    end
  end
end
