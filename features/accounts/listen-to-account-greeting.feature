Feature: Listen to account greeting

Scenario: When I haven't recorded a greeting
  Given that I am logged in
  And I visit my account page
  Then I should not see the greeting audio player

Scenario: When I have recorded a greeting
  Given that I am logged in
  And I have recorded a greeting
  And I visit my account page
  Then I should see the greeting audio player