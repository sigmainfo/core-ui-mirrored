Feature: user browses associative relations
  In order to get all available information regarding a single concept
  As a user that browses the repository
  I want to see all its associative relations

  Background:
    Given I am logged in as user of the repository

  Scenario: show different kinds of associative relations
    Given a "see also" defined relation
    And an "antonymic" defined relation
    And the repository is configured with these relations
    And a concept with label "mobile phone" exists
    And a concept with label "cell phone" exists
    And a concept with label "landline phone" exists
    And "mobile phone" concept has a "see also" relation with concept "cell phone"
    And "mobile phone" concept has an "antonymic" relation with concept "landline phone"
    When I visit the concept details page for "mobile phone"
    Then I see a section "ASSOCIATED"
    And this section displays "cell phone" as a "see also" relation
    And this section displays "landline phone" as an "antonymic" relation

  Scenario: show system info for relation
    Given a "see also" defined relation
    And the repository is configured with these relations
    And a concept with label "mobile phone" exists
    And a concept with label "cell phone" exists
    And "mobile phone" concept has a "see also" relation with concept "cell phone"
    When I visit the concept details page for "mobile phone"
    Then I see a section "ASSOCIATED"
    And this section displays "cell phone" as a "see also" relation
    Then I do not see a table with system information about the relation
    When I click the toggle "System Info" on the concept
    Then I see a table with system information about the relation

  Scenario: navigation through associated concepts
    Given a "see also" defined relation
    And an "antonymic" defined relation
    And the repository is configured with these relations
    And a concept with label "mobile phone" exists
    And a concept with label "cell phone" exists
    And "mobile phone" concept has a "see also" relation with concept "cell phone"
    When I visit the concept details page for "mobile phone"
    Then I see a section "ASSOCIATED"
    And this section displays "cell phone" as a "see also" relation
    And I click on the "cell phone" relation label
    And I am directed to the "cell phone" concept page
    Then I see a section "ASSOCIATED"
    And this section displays "mobile phone" as a "see also" relation
    And I click on the "mobile phone" relation label
    And I am directed to the "mobile phone" concept page

  Scenario: don't show empty relations
    Given a "see also" defined relation
    And an "antonymic" defined relation
    And the repository is configured with these relations
    And a concept with label "mobile phone" exists
    And a concept with label "cell phone" exists
    And "mobile phone" concept has a "see also" relation with concept "cell phone"
    When I visit the concept details page for "mobile phone"
    Then I see a section "ASSOCIATED"
    And this section displays "cell phone" as a "see also" relation
    And this section does not have an "antonymic" relation area

  Scenario: don't show associated sections if no relations defined
    Given a "see also" defined relation
    And an "antonymic" defined relation
    And the repository is configured with these relations
    And a concept with label "mobile phone" exists
    When I visit the concept details page for "mobile phone"
    Then I don't see a section "ASSOCIATED"
