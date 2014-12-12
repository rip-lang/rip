require 'spec_helper'

describe 'System.IO' do
  after(:each) { assert_exit_status(0) }

  describe '.out' do
    specify do
      write_file 'sample.rip', <<-RIP
System.IO.out('hello world')
      RIP

      run_simple 'rip execute sample.rip'

      expect(all_stdout).to eq('hello world')
    end

    specify do
      write_file 'sample.rip', <<-RIP
System.IO.out(42)
      RIP

      run_simple 'rip execute sample.rip'

      expect(all_stdout).to eq('42')
    end
  end


  describe '.error' do
    specify do
      write_file 'sample.rip', <<-RIP
System.IO.error('hello world')
      RIP

      run_simple 'rip execute sample.rip'

      expect(all_stderr).to eq('hello world')
    end

    specify do
      write_file 'sample.rip', <<-RIP
System.IO.error(42)
      RIP

      run_simple 'rip execute sample.rip'

      expect(all_stderr).to eq('42')
    end
  end


  describe '.in' do
    specify do
      write_file 'sample.rip', <<-RIP
System.IO.out(System.IO.in())
System.IO.error(System.IO.in())
      RIP

      run_interactive 'rip execute sample.rip'
      type 'standard in to standard out'
      type 'standard in to standard error'

      expect(all_stdout).to eq("standard in to standard out\n")
      expect(all_stderr).to eq("standard in to standard error\n")
    end
  end
end
