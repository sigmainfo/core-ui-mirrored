Feature: maintainer adds term
  In order to make a new term available in context of a concept
  As a maintainer updating data in the repository
  I want to add a term to an existing concept

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am a maintainer of the repository
    And the repository defines a blueprint for terms
    And that blueprint requires a property "status" of type "text"
    And that blueprint allows a property "description" of type "text"
    And that blueprint allows a property "notes" of type "text"
    And I am logged in
    And a concept "top hat" exists
    And I visit the page of this concept

  Scenario: add term
    When I toggle "EDIT MODE"
    And I click "Add term"
    Then I see a form "Create term"
    Then I should see a set of term inputs with labels "Value", "Language"
    When I fill in "Value" with "high hat" within term inputs
    And I fill in "Language" with "en" within term inputs
    And I see a section "PROPERTIES" with this form
    And I see a fieldset "STATUS" within this section
    Then I fill in "STATUS" with "pending"
    And I select "English" for "LANGUAGE"
    And I click "Add property" within term inputs
    Then I see a dropdown with options "DESCRIPTION", "NOTES"
    When I click on "DESCRIPTION"
    Then I see a fieldset "DESCRIPTION"
    And I fill in "DESCRIPTION" with "this is it"
    And I select "English" for "LANGUAGE"
    When I click "Create term"
    Then I should see a term "high hat" within language "EN"
    When I click "PROPERTIES" within term
    Then I should see a property "STATUS" for the term with value "pending"
    And I should see a property "DESCRIPTION" for the term with value "this is it"
    And I should see a message 'Successfully created term "high hat".'
    And I should not see "Create term"

  Scenario: validation errors
    When I toggle "EDIT MODE"
    And I click "Add term"
    Then I see a form "Create term"
    And client-side validation is turned off
    And I fill in "Value" with "high hat" within term inputs
    And I see a section "PROPERTIES" with this form
    And I see a fieldset "STATUS" within this section
    Then I fill in "STATUS" with "pending"
    And I click "Create term"
    Then I should see an error summary
    And this summary should contain "Failed to create term:"
    And I should see error "can't be blank" for term input "Language"
    And I fill in "Language" with "en" within term inputs
    And I click "Create term"
    Then I should see a term "high hat" within language "EN"
    And I should not see an error summary
    But I should see a message 'Successfully created term "high hat".'

  # TODO 141002 [ap] Add validation scenario for term properties

  Scenario: cancel adding term
    When I toggle "EDIT MODE"
    And I click "Add term"
    Then I see a form "Create term"
    And I fill in "Value" with "high hat" within term inputs
    And I fill in "Language" with "en" within term inputs
    And I see a section "PROPERTIES" with this form
    And I see a fieldset "STATUS" within this section
    Then I fill in "STATUS" with "pending"
    When I click "Cancel"
    Then I should not see "Create term"
    And I should not see "high hat"
    When I click "Add term"
    Then I see a form "Create term"
    Then I should see a set of term inputs with labels "Value", "Language"
    And these term inputs should be empty
    And I see a section "PROPERTIES" with this form
    And I see a fieldset "STATUS" within this section
    And this fieldset is empty
