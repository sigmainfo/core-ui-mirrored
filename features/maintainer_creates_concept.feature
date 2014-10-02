Feature: maintainer creates concept
  In order to make information available in context of a not yet existent concept
  As a maintainer that is adding data to the repository
  I want to create a new concept optionally populated with some initial terms or properties

  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    Given I am a maintainer of the repository
    And the repository defines an empty blueprint for concepts
    And the repository defines an empty blueprint for terms
    And I am logged in

  Scenario: create empty concept
    When I visit the start page
    And I click on "New concept"
    Then I should be on the new concept page
    And I should see "<New concept>" within the title
    And I should see a section "BROADER & NARROWER"
    And I should see "<New concept>" being the current selection
    And I should see "Test Repository" within the list of broader concepts
    And I should see a new concept node "<New concept>" within the concept map
    When I click "Create concept"
    Then I should be on the show concept page
    And I should see the id of the newly created concept within the title
    And I should see a new concept node with the id of the newly created concept within the concept map

  # TODO  140924 [ap,tc] Remove. Replaced by scenario "new concept with custom
  #                      property" in feature "maintainer edits properties"

  # Scenario: add property
  #   When I visit the start page
  #   And I click on "New concept"
  #   And I click "Add property"
  #   Then I should see a set of property inputs with labels "Key", "Value", "Language"
  #   When I click "Remove property" within the set
  #   Then I should not see a set of property inputs anymore
  #   When I click "Add property"
  #   And I fill "Key" with "label"
  #   And I fill "Value" with "dead man"
  #   And I click "Create concept"
  #   Then I should see "dead man" within the title
  #   And I should see a property "label" with value "dead man"

  # Scenario: add term
  #   When I visit the start page
  #   And I click on "New concept"
  #   And I click "Add term"
  #   Then I should see a set of term inputs with labels "Value", "Language"
  #   When I click "Remove term" within the set
  #   Then I should not see a set of term inputs anymore
  #   When I click "Add term"
  #   And I fill "Value" with "corpse"
  #   And I fill "Language" with "en"
  #   And I click "Create concept"
  #   Then I should see "corpse" within the title
  #   Then I should see an English term "corpse"

  Scenario: add term with property
    When I visit the start page
    And I click on "New concept"
    And I click "Add term"
    And I fill "Value" with "corpse"
    And I fill "Language" with "en"
    And I click "Add property" within the term input set
    Then I should see a set of property inputs with labels "Key", "Value", "Language"
    When I click "Remove property"
    Then I should not see a set of property inputs anymore
    When I click "Add property" within the term input set
    And I fill "Key" with "source" within the term property input set
    And I fill "Value" with "Wikipedia" within the term property input set
    And I click "Create concept"
    And I click "PROPERTIES" within term
    Then I should see a property "source" with value "Wikipedia"

  Scenario: validation errors
    When I visit the start page
    And I click on "New concept"
    And client-side validation is turned off
    And I click "Add term"
    And I fill "Value" of term with "corpse"
    And I click "Create concept"
    Then I should see an error summary
    And this summary should contain "Failed to create concept:"
    And this summary should contain "1 error on terms"
    And I should see error "can't be blank" for term input "Language"
    And I fill "Language" of term with "en"
    And I click "Create concept"
    Then I should be on the new concept page
    And I should not see an error summary
    But I should see message 'Successfully created concept "corpse".'

  Scenario: cancel creation
    When I visit the start page
    And I click on "New concept"
    When I click "Cancel"
    Then I should be on the start page again
    And I should not see "<New concept>"
    But I should see link "New concept"

  Scenario: not a maintainer
    Given I am no maintainer of the repository
    When I visit the start page
    Then I should not see link "New concept"
    When I do a search for "corpse"
    Then I should not see link "New concept"
