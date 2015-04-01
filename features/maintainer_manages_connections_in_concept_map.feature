Feature: Maintainer manages connections in concept map
  In order to change a concept's connections to other concepts
  As a maintainer browsing the concept map
  I want to be able to DnD a concept under another concept

  Background:
    Given I am logged in as maintainer of the repository
    And a concept with label "destination of transport" exists
    And the concept "destination of transport" has "intra-EU transport" as a subconcept
    And a concept with label "mode of transport" exists
    And the concept "mode of transport" has "pipeline transport" as a subconcept

  Scenario: I can see the edit mode button only when map is in Main View
    When I visit the repository root page
    Then I should see a widget "Concept Map"
    And in this widget there is no "Edit mode" button
    When I click on "Maximize" inside the widget "Concept Map"
    Then I should see a concept map inside the main view
    And in this view there is an "Edit mode" button

  Scenario: When concept map is in edit view the map is frozen
    When I visit the repository root page
    Then I should see a widget "Concept Map"
    Then I click on "Maximize" inside the widget "Concept Map"
    And I click the "Edit mode" button
    Then I cannot drag and drop the background of the map

  Scenario: When concept map is in edit view additional actions are enabled
    When I visit the repository root page
    Then I should see a widget "Concept Map"
    Then I click on "Maximize" inside the widget "Concept Map"
    And I click the "Edit mode" button
    And in this view there is an "Reset" button
    And in this view there is an "Cancel" button
    And in this view there is an "Save" button

  Scenario: I can change the superconcept of a concept by dragging it on another one
    When I visit the repository root page
    Then I should see a widget "Concept Map"
    Then I click on "Maximize" inside the widget "Concept Map"
    And I click the "Edit mode" button
    Then I drag concept "pipeline transport" on the "destination of transport" concept
    Then I see concept "pipeline transport" connected with a thick line with concept "destination of transport"
    Then I see concept "pipeline transport" connected with a dotted line with concept "mode of transport"
    When I click save
    Then I am not in edit mode
    And I see concept "pipeline transport" connected with concept "destination of transport"
    And I see concept "intra-EU transport" connected with concept "destination of transport"
    And I see concept "mode of transport" does not heave any subconcepts

  Scenario: Reset editing of concept map relations
    When I visit the repository root page
    Then I should see a widget "Concept Map"
    Then I click on "Maximize" inside the widget "Concept Map"
    And I click the "Edit mode" button
    Then I drag concept "pipeline transport" on the "destination of transport" concept
    Then I see concept "pipeline transport" connected with a thick line with concept "destination of transport"
    Then I see concept "pipeline transport" connected with a dotted line with concept "mode of transport"
    When I click "Reset"
    Then I am in edit mode
    Then I see concept "destination of transport" connected with concept "intra-EU transport"
    And I see concept "mode of transport" connected with concept "pipeline transport"
    Then I see concept "pipeline transport" has no connection with concept "destination of transport"

  Scenario: Cancel editing of concept map relations
    When I visit the repository root page
    Then I should see a widget "Concept Map"
    Then I click on "Maximize" inside the widget "Concept Map"
    And I click the "Edit mode" button
    Then I drag concept "pipeline transport" on the "destination of transport" concept
    Then I see concept "pipeline transport" connected with a thick line with concept "destination of transport"
    Then I see concept "pipeline transport" connected with a dotted line with concept "mode of transport"
    When I click "Cancel"
    Then I am not in edit mode
    Then I see concept "destination of transport" connected with concept "intra-EU transport"
    And I see concept "mode of transport" connected with concept "pipeline transport"
    Then I see concept "pipeline transport" has no connection with concept "destination of transport"








