Feature: Printing the parse tree of a Rip file

  Scenario:
    Given a sample file exists
    And I run `rip parse_tree sample.rip`
    Then I should see all the parts of the file
