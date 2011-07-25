Feature: Login to OpenVoice

Scenario: Successfully login with an account
  Given I have an account created

  When I visit the home page
  And I click Login
  And I enter my email and password
  And I press the login button

  Then I should be on my account page
  And I should see the notice "Logged in successfully"

  When I visit the homepage
  Then I should not see "Login"