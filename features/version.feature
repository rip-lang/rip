Feature: Printing version information

  Scenario: Versioning
    Given I run `rip version`
    Then I should see version information

  Scenario: Versioning with expected flag
    Given I run `rip --version`
    Then I should see version information

  Scenario: Verbose versioning
    Given I run `rip version --verbose`
    Then I should see expanded version information

  Scenario: Verbose versioning with expected flag
    Given I run `rip --version --verbose`
    Then I should see expanded version information
