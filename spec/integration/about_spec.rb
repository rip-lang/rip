require 'spec_helper'

describe 'rip about' do
  let(:logo_pattern) { /[ _\/\\]+/ }
  let(:version_pattern) { /v\d.\d.\d(-\w+(\.\d+)?)?/ }

  after(:each) do
    expect(all_stdout).to match(/^copyright/)
    assert_exit_status(0)
  end

  specify do
    run_simple 'rip about'
    expect(all_stdout).to match(/^#{version_pattern}$/)
  end

  specify do
    run_simple 'rip --version'
    expect(all_stdout).to match(/^#{version_pattern}$/)
  end

  specify do
    run_simple 'rip about --verbose'
    expect(all_stdout).to match(/^#{logo_pattern} #{version_pattern}$/)
  end

  specify do
    run_simple 'rip --version --verbose'
    expect(all_stdout).to match(/^#{logo_pattern} #{version_pattern}$/)
  end
end
