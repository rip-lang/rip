Then /^the output should contain a brief explanation for everything$/ do
  output = all_stdout

  [
    :help,
    :do,
    :version,
    :parse_tree,
    :syntax_tree
  ].each do |command|
    output.should match(/^  rip #{command} .+ # .{10,}$/), "A description for `#{command}` should probably be longer than ten characters to be useful"
  end
end

Then /^the output should contain detailed help for running the REPL$/ do
  pending # express the regexp above with the code you wish you had
end
