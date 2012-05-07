Feature: Running a Rip program

  Scenario: Running a file
    Given a sample file exists
    And I run `rip sample.rip`

  Scenario: Running a file with execute
    Given a sample file exists
    And I run `rip execute sample.rip`
