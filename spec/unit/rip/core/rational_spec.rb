require 'spec_helper'

BinaryOperator = Struct.new(:lhs, :operator, :rhs, :result)

describe Rip::Core::Rational do
  let(:context) { Rip::Compiler::Scope.new }

  let(:pi) { Rip::Core::Rational.new(314, 100) }
  let(:type_instance) { Rip::Core::Rational.type_instance }

  include_examples 'debug methods' do
    let(:type_to_s) { '#< System.Rational >' }

    let(:instance) { pi }
    let(:instance_to_s) { '#< #< System.Rational > [ %, *, +, -, /, /%, ==, to_integer, to_rational, to_string, type ] numerator = 157, denominator = 50 >' }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['type']).to eq(Rip::Core::Type.type_instance) }
  end

  describe '@.type' do
    specify { expect(pi['type']).to be(type_instance) }
  end

  describe '@.to_boolean' do
    specify { expect(pi['to_boolean'].call([])).to eq(Rip::Core::Boolean.true) }
  end

  describe '@.to_string' do
    specify { expect(pi['to_string'].call([]).to_native).to eq('(157 / 50)') }
  end

  describe '@.==' do
    let(:a) { Rip::Core::Rational.new(1, 2) }
    let(:b) { Rip::Core::Rational.new(2, 4) }

    specify { expect(a['=='].call([ b ])).to eq(Rip::Core::Boolean.true) }
  end

  [
    BinaryOperator.new([11, 111], :+, [22, 222], [22, 111]),
    BinaryOperator.new([65, 42], :+, [-42, 84], [22, 21]),
    BinaryOperator.new([-42, 84], :+, [84, 85], [83, 170]),
    BinaryOperator.new([84, 85], :+, [85, 82], [14113, 6970]),

    BinaryOperator.new([85, 82], :-, [82, 56], [-491, 1148]),
    BinaryOperator.new([82, 56], :-, [-56, 5], [1773, 140]),
    BinaryOperator.new([-56, 5], :-, [-5, 89], [-4959, 445]),
    BinaryOperator.new([-5, 89], :-, [89, 28], [-8061, 2492]),

    BinaryOperator.new([89, 28], :*, [-28, 77], [-89, 77]),
    BinaryOperator.new([-28, 77], :*, [-77, 80], [7, 20]),
    BinaryOperator.new([-77, 80], :*, [-80, 81], [77, 81]),
    BinaryOperator.new([-80, 81], :*, [-81, 69], [80, 69]),

    BinaryOperator.new([-81, 69], :/, [69, 14], [-126, 529]),
    BinaryOperator.new([69, 14], :/, [14, 80], [1380, 49]),
    BinaryOperator.new([43, 34], :/, [-34, 17], [-43, 68]),
    BinaryOperator.new([-34, 17], :/, [-17, 6], [12, 17]),

    BinaryOperator.new([-36, 38], :%, [38, 91], [528, 1729]),
    BinaryOperator.new([38, 91], :%, [-91, 39], [-523, 273]),
    BinaryOperator.new([-91, 39], :%, [-39, 63], [-10, 21]),
    BinaryOperator.new([-39, 63], :%, [63, 87], [64, 609])
  ].each do |bo|
    describe "type_instance.#{bo.operator}" do
      let(:lhs) { Rip::Core::Rational.new(*bo.lhs) }
      let(:rhs) { Rip::Core::Rational.new(*bo.rhs) }
      let(:result) { Rip::Core::Rational.new(*bo.result) }

      specify { expect(Rip::Core::Rational.type_instance[bo.operator].call([ lhs, rhs ])).to eq(result) }
    end
  end

  describe '@./%' do
    let(:half) { Rip::Core::Rational.new(1, 2) }
    let(:third) { Rip::Core::Rational.new(1, 3) }
    let(:three_halfs) { Rip::Core::Rational.new(3, 2) }
    let(:sixth) { Rip::Core::Rational.new(1, 6) }

    let(:tuple) { Rip::Core::List.new([ three_halfs, sixth ]) }

    specify { expect(half['/%'].call([ third ])).to eq(tuple) }
  end
end
