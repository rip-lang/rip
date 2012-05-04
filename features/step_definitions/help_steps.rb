Then /^the output should contain a brief explanation for each command$/ do
  output = all_stdout

  [
    :do,
    :help,
    :repl,
    :parse_tree,
    :syntax_tree
  ].each do |command|
    output.should match(/^  rip #{command} .+ # .{10,}$/), "A description for `#{command}` should probably be longer than ten characters to be useful"
  end
end
