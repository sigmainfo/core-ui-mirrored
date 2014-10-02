Feature: maintainer edits properties
  In order to provide users with relevant meta data
  As a maintainer editing concepts and terms
  I want to create, update and delete individual properties

  Background:
    Given I am logged in as maintainer of the repository

  Scenario: new concept with defaults
    Given the repository defines a blueprint for concepts
    And that blueprint defines a property "definition" of type "multiline text"
    And that blueprint defines a property "dangerous" of type "boolean"
    When I visit the repository root page
    And I click on "New concept"
    Then I see a section "PROPERTIES" within the form "Create concept"
    And I see a fieldset with key "definition" within this section
    And this fieldset contains a text area "VALUE"
    And this fieldset contains a select "LANGUAGE"
    And I see a fieldset with key "dangerous" within this section
    And this fieldset contains a checkbox "VALUE"
    And this fieldset does not contain a select "LANGUAGE"
    When I fill "VALUE" for "definition" with "sucks blood; bat"
    And I select "English" as "LANGUAGE" for "definition"
    And I uncheck "VALUE" for "dangerous"
    And I click "Create concept"
    Then I see a listing "PROPERTIES" within the concept header
    And I see a property "DEFINITION" with English value "sucks blood; bat"
    And I see a property "DANGEROUS" that is unchecked

  # @wip
  # Scenario: new concept with custom property
  #   When I visit the repository root page
  #   And I click on "New concept"
  #   Then I see a section "PROPERTIES" within the form "Create concept"
  #   When I click "Add property" within this form
  #   Then I see a fieldset with input "KEY" that is empty
  #   When I fill in "quote" for "KEY"
  #   And I fill in "That certainly was visual." for "VALUE"
  #   And I select "None" for "LANGUAGE"
  #   When I click "Add property" within this form
  #   And I click "Create concept"
  #   Then I see a listing "PROPERTIES" within the concept header
  #   And I see a property "QUOTE" with value "That certainly was visual."

  # @wip
  # Scenario: edit existing concept properties
  #   Given the repository defines a blueprint for concepts
  #   And that blueprint defines a property "tags" of type "multiselect picklist"
  #   And that property allows values: "cool", "night life", "diet"
  #   And a concept "Bloodbath" exists
  #   And that concept has a property "rating" with value "+++++"
  #   When I edit that concept
  #   Then I see a section "PROPERTIES" within the form "Update concept"
  #   And I see a fieldset with key "tags" within this section
  #   And this fieldset contains checkboxes for "cool", "night life", "diet"
  #   And I see a fieldset with key "rating" within this section
  #   And this fieldset contains an input "VALUE"
  #   And this fieldset contains a select "LANGUAGE" with "None" selected
  #   When I check "cool", "night life" inside "VALUE" for "tags"
  #   And I click "Update concept"
  #   Then I see a listing "PROPERTIES" within the concept header
  #   And I see a property "TAGS" with values "cool", "night life" only
  #   And I see a property "RATING" with value "+++++"

  # @wip
  # Scenario: add term with custom property
  #   Given a concept "Bloodbath" exists
  #   When I edit that concept
  #   And I click "Add term"
  #   Then I see a section "PROPERTIES" within the form "Add term"
  #   When I fill in "Blutbad" for "VALUE"
  #   And I select "de" for "LANGUAGE"
  #   When I click "Add property" within this form
  #   And I fill in "Author" for "KEY"
  #   And I fill in "Rüdiger von Schlotterstein" for "VALUE"
  #   And I click "Add term"
  #   Then I see term "Blutbad" within language section "DE"
  #   When I toggle "Properties" within this term
  #   Then I see a property "AUTHOR" with value "Rüdiger von Schlotterstein"

  # @wip
  # Scenario: edit term defaults
  #   Given the repository defines a blueprint for terms
  #   And that blueprint defines a property "since" of type "date"
  #   And a concept with English term "bloodbath" exists
  #   When I edit that concept
  #   And I click "Edit term" within the term "bloodbath"
  #   Then I see a section "PROPERTIES" within the form "Update term"
  #   And I see a fieldset with key "since" within this section
  #   And this fieldset contains 3 selects for "VALUE"
  #   When I select "16", "Aug", "2014" as "VALUE" for "since"
  #   And I click "Update term"
  #   Then I see term "bloodbath" within language section "EN"
  #   When I toggle "Properties" within this term
  #   Then I see a property "SINCE" with value "Aug 16, 2014"

  # @wip
  # Scenario: remove custom property
  #   Given the repository defines a blueprint for concepts
  #   And that blueprint defines a property "mentions" of type "number"
  #   And a concept "Bloodbath" exists
  #   And that concept has a property "fun factor" with value "23.8"
  #   When I edit that concept
  #   Then I see a section "PROPERTIES" within the form "Create concept"
  #   And I see a fieldset with key "mentions" within this section
  #   And this fieldset does not contain a link "Remove property"
  #   And I see a fieldset with key "fun factor" within this section
  #   When I click "Remove property" within this fieldset
  #   And I click "Update concept"
  #   Then I see a listing "PROPERTIES" within the concept header
  #   And I see a property "MENTIONS"
  #   But I do not see a property "FUN FACTOR"

  # TODO 140916 [tc] cleanup deprecated scenarios inside existing features
