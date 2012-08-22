Then /^I should see (expanded )?version information$/ do |expand|
  expand_text = expand ? 'Rip version ' : ''
  all_stdout.should =~ /^#{expand_text}\d\.\d\.\d$/
end
