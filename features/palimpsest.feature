Feature: Move selection to the top of the buffer

  In order to move selection to the top of the buffer
  As a user
  I want to select text and send it to the top
  with palimpsest-move-region-to-top

  Scenario: Move line 3 to buffer's first line
    Given I am in buffer "*palimpsest*"
    And the buffer is empty
    When I insert:
    """
    line 1
    line 2
    line 3
    line 4
    line 5
    """
    # TODO: include newline in selection
    And I select "line 3"
    And I call "palimpsest-move-region-to-top"
    Then I should see:
    """
    line 3
    line 1
    line 2

    line 4
    line 5
    """


  Scenario: Move line 3 to buffer's bottom line
    Given I am in buffer "*palimpsest*"
    And the buffer is empty
    When I insert:
    """
    line 1
    line 2
    line 3
    line 4
    line 5

    """
    And I select "line 3"
    And I call "palimpsest-move-region-to-bottom"
    Then I should see:
    """
    line 1
    line 2

    line 4
    line 5
    line 3
    """
