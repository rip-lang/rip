Then /^the output should contain a brief explanation for everything$/ do
  output = all_stdout

  most_actions.each do |command|
    output.should match(/^  rip #{command} .+ # .{10,}$/), "A description for `#{command}` should probably be longer than ten characters to be useful"
  end

  global_options.each do |option|
    output.should match(/^  \[--#{option}\] + # .{10,}$/), "A description for `--#{option}` should probably be longer than ten characters to be useful"
  end
end

Then /^the output should contain detailed help for running the REPL$/ do
  pending # express the regexp above with the code you wish you had
end
