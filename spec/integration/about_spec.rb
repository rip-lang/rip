require 'spec_helper'

describe 'rip about' do
  after(:each) { assert_exit_status(0) }

  specify do
    run_simple 'rip about'
    expect(all_stdout).to match(/^\d.\d.\d$/)
  end

  specify do
    run_simple 'rip --version'
    expect(all_stdout).to match(/^\d.\d.\d$/)
  end

  specify do
    run_simple 'rip about --verbose'
    expect(all_stdout).to match(/^Rip version \d.\d.\d$/)
  end

  specify do
    run_simple 'rip --version --verbose'
    expect(all_stdout).to match(/^Rip version \d.\d.\d$/)
  end
end
