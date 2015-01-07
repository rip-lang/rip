require 'spec_helper'

describe 'System.Number' do
  after(:each) { assert_exit_status(0) }

  context 'convert between integers and rationals' do
    let(:answer) { '42' }
    let(:answer_to_s) { '42' }

    let(:pi) { '3.14' }
    let(:pi_to_s) { '(157 / 50)' }

    specify 'integer to rational' do
      expect(<<-RIP).to output_as(answer_to_s)
        System.IO.out(#{answer})
      RIP
    end

    specify 'rational to integer' do
      expect(<<-RIP).to output_as(pi_to_s)
        System.IO.out(#{pi})
      RIP
    end
  end

  describe do
    one_to_s = '1'

    two_i = '2'
    two_d = '2.0'

    three_i = '3'
    three_d = '3.0'
    three_to_s = '3'

    nine_halfs_to_s = '(9 / 2)'

    five_to_s = '5'

    six_to_s = '6'

    nine_i = '9'
    nine_d = '9.0'

    [
      [ two_i, :+, three_i, five_to_s, 'integer + integer' ],
      [ two_i, :+, three_d, five_to_s, 'integer + rational' ],
      [ two_d, :+, three_i, five_to_s, 'rational + integer' ],
      [ two_d, :+, three_d, five_to_s, 'rational + rational' ],

      [ nine_i, :-, three_i, six_to_s, 'integer - integer' ],
      [ nine_i, :-, three_d, six_to_s, 'integer - rational' ],
      [ nine_d, :-, three_i, six_to_s, 'rational - integer' ],
      [ nine_d, :-, three_d, six_to_s, 'rational - rational' ],

      [ two_i, :*, three_i, six_to_s, 'integer * integer' ],
      [ two_i, :*, three_d, six_to_s, 'integer * rational' ],
      [ two_d, :*, three_i, six_to_s, 'rational * integer' ],
      [ two_d, :*, three_d, six_to_s, 'rational * rational' ],

      [ nine_i, :/, three_i, three_to_s, 'integer / integer (without remainder)' ],
      [ nine_i, :/, two_i, nine_halfs_to_s, 'integer / integer (with remainder)' ],
      [ nine_i, :/, three_d, three_to_s, 'integer / rational' ],
      [ nine_d, :/, three_i, three_to_s, 'rational / integer' ],
      [ nine_d, :/, three_d, three_to_s, 'rational / rational' ],

      [ nine_i, :%, two_i, one_to_s, 'integer % integer' ],
      [ nine_i, :%, two_d, one_to_s, 'integer % rational' ],
      [ nine_d, :%, two_i, one_to_s, 'rational % integer' ],
      [ nine_d, :%, two_d, one_to_s, 'rational % rational' ]
    ].each do |(a, operator, b, result, message)|
      specify message do
        expect(<<-RIP).to output_as(result)
          # #{message}
          System.IO.out(#{a} #{operator} #{b}) # #{result}
        RIP
      end
    end
  end

  describe '@.round' do
    it 'rounds to specified decimal places' do
      expect(<<-RIP).to output_as('(1571 / 500)', 'round.rip')
        System.IO.out(3.14159.round(3))
      RIP
    end
  end

  describe '@.round_up' do
    it 'rounds positive up to the nearest whole number' do
      expect(<<-RIP).to output_as('4', 'positive_ceiling.rip')
        System.IO.out(3.14.round_up())
      RIP
    end

    it 'rounds negative up to the nearest whole number' do
      expect(<<-RIP).to output_as('-3', 'negative_ceiling.rip')
        System.IO.out(-3.14.round_up())
      RIP
    end
  end

  describe '@.round_down' do
    it 'rounds positive down to the nearest whole number' do
      expect(<<-RIP).to output_as('3', 'positive_floor.rip')
        System.IO.out(3.14.round_down())
      RIP
    end

    it 'rounds negative down to the nearest whole number' do
      expect(<<-RIP).to output_as('-4', 'negative_floor.rip')
        System.IO.out(-3.14.round_down())
      RIP
    end
  end
end
