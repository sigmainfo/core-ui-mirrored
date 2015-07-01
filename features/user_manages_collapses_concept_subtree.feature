Feature: user manages collapse concept subtree
  In order to click concept map node
  As a maintainer browsing the concept map
  I want to be able to click on concept node and view the concept node

  Background:
    Given I am logged in as maintainer of the repository
    And a concept with label "destination of transport" exists
    And the concept "destination of transport" has "intra-EU transport" as a subconcept
    And a concept with label "mode of transport" exists
    And the concept "mode of transport" has "pipeline transport" as a subconcept
    And I visit the repository root page
    And I should see a widget "Concept Map"
    And I click on "Maximize" inside the widget "Concept Map"

  @firefox
  Scenario: view the map and click a concept node
    Then I expanded tree
    When I click a concept node "mode of transport"
    And It should not collapse the tree
    And I can see the opened sub concept node "pipeline transport" of concept node "mode of transport"

  @firefox
  Scenario: I can click a node and can view same node details in edit widget
    Then I expanded tree
    When I click a concept node "mode of transport"
    And I can see the clicked node "mode of transport" details in right side widget

  @firefox
  Scenario: view the map/tree and expand tree
    Then I expanded tree only first level
    When I can not see second level nodes like "intra-EU transport" and "pipeline transport"
    When I click a concept node "intra-EU transport" and "pipeline transport" to expand
    And I can see the "intra-EU transport" expanded
    And I can see the "pipeline transport" expanded


  @firefox
  Scenario: view the map/tree and collapse tree
    Then I expanded tree
    When I collapse a concept node "intra-EU transport"
    And I can not see the "intra-EU transport" now because its collapsed
    And I can see the "pipeline transport" expanded


  @firefox
  Scenario: view the map/tree and collapse multiple parent concept node of expanded tree
    And the concept "destination of transport" and "mode of transport" has "common of transport" as a subconcept
    Then I expanded tree
    And I can see the "intra-EU transport" expanded
    And I can see the "pipeline transport" expanded
    When I collapse a concept node "common of transport"
    Then I can not see the "common of transport" now because its collapsed
    And "destination of transport" should have placeholder for collapsed node
    And "mode of transport" should have placeholder for collapsed node
    When I expand "mode of transport" concept
    Then "destination of transport" should not have any placeholder for collapsed node
    And "mode of transport" should not have placeholder for multi sub node collapsed node
    And "destination of transport" now have one concept only as a placeholder now

  @firefox
  Scenario: tree portrait to landscape mode
    Then I expanded tree
    And I can see the "intra-EU transport" expanded
    And I can see the "pipeline transport" expanded
    When I change from portrait to landscape mode
    And I can see the "intra-EU transport" expanded
    And I can see the "pipeline transport" expanded
    When I change from landscape to portrait mode
    And I can see the "intra-EU transport" expanded
    And I can see the "pipeline transport" expanded
    When I collapse a concept node "common of transport"
    Then I can not see the "common of transport" now because its collapsed
    When I change from portrait to landscape mode
    Then I can not see the "common of transport" now because its collapsed
    When I change from landscape to portrait mode
    Then I can not see the "common of transport" now because its collapsed
