require 'spec_helper'

describe 'rip execute', :blur do
  before(:each) do
    write_file 'sample.rip', <<-RIP
System.IO.out(42)
    RIP
  end

  after(:each) { assert_exit_status(0) }

  # specify do
  #   run_simple 'rip sample.rip'
  #   expect(all_stdout).to eq("42\n")
  # end

  specify do
    run_simple 'rip execute sample.rip'
    expect(all_stdout).to eq("42\n")
  end
end
