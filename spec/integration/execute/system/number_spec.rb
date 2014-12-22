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
end
