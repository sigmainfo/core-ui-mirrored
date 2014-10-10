Feature: maintainer edits properties
  In order to provide users with relevant meta data
  As a maintainer editing concepts and terms
  I want to create, update and delete individual properties

  Background:
    Given I am logged in as maintainer of the repository

  @wip
  Scenario: new concept with required properties
    Given the repository defines a blueprint for concepts
    And that blueprint requires a property "short description" of type "text"
    And that blueprint requires a property "dangerous" of type "boolean"
    And that property defines labels "yes" and "no"
    When I visit the repository root page
    And I click on "New concept"
    Then I see a section "PROPERTIES" within the form "Create concept"
    And I see a fieldset "SHORT DESCRIPTION" within this section
    And this fieldset contains a text input
    And this fieldset contains a select "LANGUAGE"
    And I see a fieldset "DANGEROUS" within this section
    And this fieldset contains radio buttons "yes" and "no"
    And this fieldset does not contain a select "LANGUAGE"
    When I fill in "SHORT DESCRIPTION" with "sucks blood; bat"
    And I select "English" for "LANGUAGE"
    And I select "no" for "DANGEROUS"
    And I click "Create concept"
    Then I see a listing "PROPERTIES" within the concept header
    And I see a property "DEFINITION" with English value "sucks blood; bat"
    And I see a property "DANGEROUS" with value "yes"

  @wip
  Scenario: new concept with optional property
    Given the repository defines a blueprint for concepts
    And that blueprint allows a property "alias" of type "text"
    And that blueprint allows a property "definition" of type "multiline text"
    When I visit the repository root page
    And I click on "New concept"
    Then I see a section "PROPERTIES" within the form "Create concept"
    And I do not see a fieldset "ALIAS" or "DEFINITION"
    When I click on "Add property" within this form
    Then I see a dropdown with options "ALIAS", "DEFINITION"
    When I click on "DEFINITION"
    Then I see a fieldset "DEFINITION"
    When I fill in "Corpse that drinks blood of the living." for "DEFINITION"
    And I select "None" for "LANGUAGE"
    And I click "Create concept"
    Then I see a listing "PROPERTIES" within the concept header
    And I see a "DEFINITION" with "Corpse that drinks blood of the living."

  @wip
  Scenario: edit existing concept property
    Given the repository defines a blueprint for concepts
    And that blueprint requires a property "tags" of type "multiselect picklist"
    And that property allows values: "cool", "night life", "diet"
    And a concept "Bloodbath" exists
    When I edit that concept
    Then I see a section "PROPERTIES"
    When I click on "Edit properties"
    Then I see a form "Save concept"
    And I see a fieldset "TAGS" within this form
    And this fieldset contains checkboxes for "cool", "night life", "diet"
    When I check "cool" and "night life"
    And I click "Save concept"
    Then I see a listing "PROPERTIES" within the concept header
    And I see a property "TAGS" with values "cool", "night life" only

  @wip
  Scenario: edit deprecated concept property
    Given the repository defines a blueprint for concepts
    And that blueprint does not require any properties
    And a concept "Bloodbath" exists
    And that concept has a property "rating" with value "+++++"
    When I edit that concept
    And I click on "Edit properties"
    Then I see a form "Save concept"
    And I see a fieldset "RATING" that is not editable
    When I click on "Delete property"
    And I click "Save concept"
    Then I see a listing "PROPERTIES" within the concept header
    But I do not see "RATING" or "+++++"

  @wip
  Scenario: ensure non-blank property on new term
    Given the repository defines a blueprint for terms
    And that blueprint requires a property "author" of type "text"
    And a concept "Bloodbath" exists
    When I edit that concept
    And I click "Add term"
    Then I see a section "PROPERTIES" within the form "Add term"
    When I fill in "Blutbad" for "VALUE"
    And I select "de" for "LANGUAGE"
    And I click "Add property" within this form
    Then the submit "Add term" is disabled
    When I fill in "Rüdiger von Schlotterstein" for "AUTHOR"
    Then the submit "Add term" is enabled
    When I click "Add term"
    Then I see term "Blutbad" within language section "DE"
    When I toggle "Properties" within this term
    Then I see a property "AUTHOR" with value "Rüdiger von Schlotterstein"

  @wip
  Scenario: add another value when editing term
    Given the repository defines a blueprint for terms
    And that blueprint defines a property "source" of type "url"
    And a concept with English term "bloodbath" exists
    And that term has a property "source" of "http://bloodbathproject.com"
    When I edit that concept
    And I click "Edit term" within the term "bloodbath"
    Then I see a section "PROPERTIES" within the form "Update term"
    And I see a fieldset "SOURCE" within this section
    And I see an input with "bloodbathproject.com"
    When I click on "Add value" inside "SOURCE"
    And I fill in the empty input with "http://en.wikipedia.org/wiki/Bloodbath"
    And I click "Update term"
    Then I see term "bloodbath" within language section "EN"
    When I toggle "Properties" within this term
    Then I see a property "SINCE" with 2 values
    When I click "2"
    Then I see a link "http://en.wikipedia.org/wiki/Bloodbath"
