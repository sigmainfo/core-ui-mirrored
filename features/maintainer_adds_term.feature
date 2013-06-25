Feature: maintainer adds term
  In order to make a new term available in context of a concept
  As a maintainer updating data in the repository
  I want to add a term to an existing concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in
    And a concept "top hat" exists
  
  Scenario: add term
    Given I have maintainer privileges
    And I visit the page of this concept
    When I click "Edit concept" 
    And I click "Add term"
    Then I should see a set of term inputs with labels "Value", "Language"
    When I fill in "Value" with "high hat" within term inputs
    And I fill in "Language" with "en" within term inputs
    And I click "Add property" within term inputs
    Then I should see a set of property inputs with labels "Key", "Value", "Language"
    When I fill in "Key" with "status" within property inputs
    And I fill in "Value" with "pending" within property inputs
    When I click "Create term"
    Then I should see a term "high hat" within language "EN"
    When I click "PROPERTIES" within term
    Then I should see a property "STATUS" for the term with value "pending"
    And I should see a message 'Successfully created term "high hat".'
    And I should not see "Create term"

  Scenario: validation errors
    Given I have maintainer privileges
    And I visit the page of this concept
    When I click "Edit concept"
    And I click "Add term"
    And client-side validation is turned off
    And I fill in "Value" with "high hat" within term inputs
    And I click "Add property" within term inputs
    And I fill in "Value" with "pending" within property inputs
    And I click "Create term"
    Then I should see an error summary
    And this summary should contain "Failed to create term:"
    And this summary should contain "1 error on properties"
    And I should see error "can't be blank" for term input "Language"
    And I should see error "can't be blank" for property input "Key" within term inputs
    When I click "Remove property" within term inputs
    And I fill in "Language" with "en" within term inputs
    And I click "Create term"
    Then I should see a term "high hat" within language "EN"
    And I should not see an error summary
    But I should see a message 'Successfully created term "high hat".'

  Scenario: cancel adding term
    Given I have maintainer privileges
    And I visit the page of this concept
    When I click "Edit concept" 
    And I click "Add term"
    And I fill in "Value" with "high hat" within term inputs
    And I fill in "Language" with "en" within term inputs
    And I click "Add property" within term inputs
    When I fill in "Key" with "status" within property inputs
    And I fill in "Value" with "pending" within property inputs
    When I click "Cancel"
    Then I should not see "Create term"
    And I should not see "high hat"
    When I click "Add term"
    Then I should see a set of term inputs with labels "Value", "Language"
    And these term inputs should be empty
    And I should not see property inputs
