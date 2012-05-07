Given /^a sample file exists$/ do
  write_file 'sample.rip', <<-RIP
language = :Rip
Kernel.IO.out("\#{language}!" * 5)
  RIP
end
