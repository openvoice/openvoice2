Feature: Logout of OpenVoice

Scenario: When I am logged in
  Given that I am logged in
  When I click Logout
  Then I should be logged out
  And I should see the notice "You have been logged out"
  And I should be on the home page