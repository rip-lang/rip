Feature: Printing the syntax tree of a Rip file

  Scenario:
    Given a sample file exists
    And I run `rip syntax_tree sample.rip`
    Then I should see the syntax tree of the file
