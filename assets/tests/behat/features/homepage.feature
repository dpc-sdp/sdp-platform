Feature: Homepage

  Ensure that homepage is displayed as expected

  @api @smoke
  Scenario: Anonymous user visits homepage
    Given I go to the homepage
    And I am in the "<front>" path
    And I see the text "Single Digital Presence Content Management System"
    Then I save screenshot

  @api @javascript @smoke
  Scenario: Anonymous user visits homepage
    Given I go to the homepage
    And I am in the "<front>" path
    Then I save screenshot

