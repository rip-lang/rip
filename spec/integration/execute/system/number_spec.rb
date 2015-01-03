require 'spec_helper'

describe 'System.Number' do
  after(:each) { assert_exit_status(0) }

  context 'convert between integers and rationals' do
    let(:answer_i) { '42' }
    let(:answer_r_to_s) { '(42 / 1)' }

    let(:pi_r) { '3.14' }
    let(:pi_i_to_s) { '3' }

    specify 'integer to rational' do
      expect(<<-RIP).to output_as(answer_r_to_s)
        System.IO.out(#{answer_i}.to_rational())
      RIP
    end

    specify 'rational to integer' do
      expect(<<-RIP).to output_as(pi_i_to_s)
        System.IO.out(#{pi_r}.to_integer())
      RIP
    end
  end

  describe do
    one_i_to_s = '1'
    one_r_to_s = '(1 / 1)'

    two_i = '2'
    two_d = '2.0'

    three_i = '3'
    three_d = '3.0'
    three_i_to_s = '3'
    three_r_to_s = '(3 / 1)'

    four_i_to_s = '4'

    five_i_to_s = '5'
    five_r_to_s = '(5 / 1)'

    six_i_to_s = '6'
    six_r_to_s = '(6 / 1)'

    nine_i = '9'
    nine_d = '9.0'

    [
      [ two_i, :+, three_i, five_i_to_s, 'integer + integer, integer result' ],
      [ two_i, :+, three_d, five_r_to_s, 'integer + rational, rational result' ],
      [ two_d, :+, three_i, five_r_to_s, 'rational + integer, rational result' ],
      [ two_d, :+, three_d, five_r_to_s, 'rational + rational, rational result' ],

      [ nine_i, :-, three_i, six_i_to_s, 'integer - integer, integer result' ],
      [ nine_i, :-, three_d, six_r_to_s, 'integer - rational, rational result' ],
      [ nine_d, :-, three_i, six_r_to_s, 'rational - integer, rational result' ],
      [ nine_d, :-, three_d, six_r_to_s, 'rational - rational, rational result' ],

      [ two_i, :*, three_i, six_i_to_s, 'integer * integer, integer result' ],
      [ two_i, :*, three_d, six_r_to_s, 'integer * rational, rational result' ],
      [ two_d, :*, three_i, six_r_to_s, 'rational * integer, rational result' ],
      [ two_d, :*, three_d, six_r_to_s, 'rational * rational, rational result' ],

      [ nine_i, :/, three_i, three_i_to_s, 'integer / integer, integer result (no remainder)' ],
      [ nine_i, :/, two_i, four_i_to_s, 'integer / integer, integer result (discard remainder)' ],
      [ nine_i, :/, three_d, three_r_to_s, 'integer / rational, rational result' ],
      [ nine_d, :/, three_i, three_r_to_s, 'rational / integer, rational result' ],
      [ nine_d, :/, three_d, three_r_to_s, 'rational / rational, rational result' ],

      [ nine_i, :%, two_i, one_i_to_s, 'integer % integer, integer result' ],
      [ nine_i, :%, two_d, one_r_to_s, 'integer % rational, rational result' ],
      [ nine_d, :%, two_i, one_r_to_s, 'rational % integer, rational result' ],
      [ nine_d, :%, two_d, one_r_to_s, 'rational % rational, rational result' ]
    ].each do |(a, operator, b, result, message)|
      specify message do
        expect(<<-RIP).to output_as(result)
          # #{message}
          System.IO.out(#{a} #{operator} #{b}) # #{result}
        RIP
      end
    end
  end
end
