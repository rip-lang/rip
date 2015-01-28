require 'spec_helper'

describe 'rip help' do
  before(:each) { run_simple 'rip help' }

  after(:each) { assert_exit_status(0) }

  specify do
    expect(all_stdout).to match(/^  rip about .+ # .{10,}$/)
    expect(all_stdout).to match(/^  rip execute .+ # .{10,}$/)
    expect(all_stdout).to match(/^  rip help .+ # .{10,}$/)
    expect(all_stdout).to match(/^  rip repl .+ # .{10,}$/)
    expect(all_stdout).to match(/^  rip debug .+ # .{10,}$/)
  end

  specify do
    expect(all_stdout).to match(/^  \[--verbose\], \[--no-verbose\] + # .{10,}$/)
  end
end
