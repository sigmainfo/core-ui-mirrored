Feature: user switches ui theme
  In order to give a presentations on a faint beamer
  As a user presenting my data to a broader audience
  I want to increase the contrast of the user interface


  Background:
    Given my name is "William Blake" with email "nobody@blake.com" and password "se7en!"
    And I am logged in

  Scenario: switch theme
    Given I am on the repository root page
    When I click to toggle the footer
    And I click on theme "High Contrast"
    Then the body should have a pure white background
    When I click on theme "Default"
    Then the body should have a background image applied to it
