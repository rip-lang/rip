Feature: Getting help from the command line

  Scenario: General help
    Given I run `rip help`
    Then the output should contain a brief explanation for everything

  Scenario: General help with expected flag
    Given I run `rip --help`
    Then the output should contain a brief explanation for everything

  Scenario: Specific help
    Given I run `rip help repl`
    Then the output should contain detailed help for running the REPL
