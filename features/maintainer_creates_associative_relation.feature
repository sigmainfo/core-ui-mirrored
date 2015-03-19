Feature: maintainer creates associative relation
  In order to relate two concepts based on a predefined associative relation type
  As a maintainer who is adding data to the repository
  I want to create a new associative relation between two existing concepts

Background:
    Given I am logged in as maintainer of the repository

  Scenario: create associative relation using cliboard dropzone
    Given a "see also" defined relation
    And the repository is configured with these relation(s)
    And a concept with label "mobile phone" exists
    And a concept with label "cell phone" exists
    Then I visit the concept details page for "mobile phone"
    And I drag the concept label to the cliboard
    Then I search for "cell phone"
    And I click on the search result
    And I toggle "EDIT MODE"
    And I click "Edit relations" within "ASSOCIATED" section
    And I drag the clipped concept to the "see also" dropzone
    Then I should see "mobile phone" unsaved as associated relation
    And I should see reset, cancel and save buttons
    When I click save
    Then I am no longer in "edit relations" mode
    Then the concept "cell phone" displays "mobile phone" as a "see also" relation
