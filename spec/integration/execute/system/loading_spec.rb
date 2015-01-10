require 'spec_helper'

describe 'System.require' do
  after(:each) { assert_exit_status(0) }

  context 'relative to loading module' do
    before(:each) do
      write_file('main.rip', <<-RIP)
        result = System.require('./source/foo')
        System.IO.out(result)
      RIP

      write_file('source/foo.rip', <<-RIP)
        helper = System.require('../lib/helper')
        helper(:cat)
      RIP

      write_file('lib/helper.rip', <<-RIP)
        -> (word) {
          word.uppercase()
        }
      RIP
    end

    specify do
      run_simple 'rip execute main.rip'
      expect(all_stdout).to eq('CAT')
    end
  end
end
