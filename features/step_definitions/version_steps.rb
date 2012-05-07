Then /^I should see (expanded )?version information$/ do |expand|
  all_stdout.should =~ /\d\.\d\.\d/

  if expand
    all_stdout.should =~ /Rip version \d\.\d\.\d/
  end
end
