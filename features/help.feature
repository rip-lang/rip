Feature: Getting help from the command line

  Scenario: General help
    Given I run `rip help`
    Then the output should contain a brief explanation for each command
