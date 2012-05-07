Feature: Build system

  Scenario: Running a task
    Given I run `rip do build_rip`
    Then a new version of Rip should be compiled
