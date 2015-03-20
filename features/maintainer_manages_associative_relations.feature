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

  Scenario: disconnect associated concepts
    Given a "see also" defined relation
    And the repository is configured with these relation(s)
    And a concept with label "mobile phone" exists
    And a concept with label "cell phone" exists
    And "mobile phone" concept has a "see also" relation with concept "cell phone"
    When I visit the concept details page for "mobile phone"
    And I toggle "EDIT MODE"
    And I click "Edit relations" within "ASSOCIATED" section
    Then I should see "cell phone" in the "see also" associated relation dropzone
    And I drag the "cell phone" concept label just outside the "see also" dropzone
    Then the "see also" dropzone should be empty
    And I should see reset, cancel and save buttons
    When I click save
    Then I am no longer in "edit relations" mode
    And this section has an empty "see also" relation

  Scenario: cancel editing of associated relations
    Given a "see also" defined relation
    And the repository is configured with these relation(s)
    And a concept with label "mobile phone" exists
    And a concept with label "cell phone" exists
    And "mobile phone" concept has a "see also" relation with concept "cell phone"
    When I visit the concept details page for "mobile phone"
    And I toggle "EDIT MODE"
    And I click "Edit relations" within "ASSOCIATED" section
    Then I should see "cell phone" in the "see also" associated relation dropzone
    And I drag the "cell phone" concept label just outside the "see also" dropzone
    Then the "see also" dropzone should be empty
    And I should see reset, cancel and save buttons
    When I click cancel
    Then I am no longer in "edit relations" mode
    Then the concept "mobile phone" displays "cell phone" as a "see also" relation

  Scenario: reset editing of associated relations
    Given a "see also" defined relation
    And the repository is configured with these relation(s)
    And a concept with label "mobile phone" exists
    And a concept with label "cell phone" exists
    And "mobile phone" concept has a "see also" relation with concept "cell phone"
    When I visit the concept details page for "mobile phone"
    And I toggle "EDIT MODE"
    And I click "Edit relations" within "ASSOCIATED" section
    Then I should see "cell phone" in the "see also" associated relation dropzone
    And I drag the "cell phone" concept label just outside the "see also" dropzone
    Then the "see also" dropzone should be empty
    And I should see reset, cancel and save buttons
    When I click reset
    Then I should see "cell phone" in the "see also" associated relation dropzone

