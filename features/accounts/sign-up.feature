Feature: Sign up for an OpenVoice account

Scenario: A signup

  When I visit the home page
  And I click sign up
  And I enter my email, password and password confirmation
  And I press the sign up button

  Then I should see the notice "Your account has been created successfully"
  And I should be logged in
  And I should be on my account page

Scenario: An unsuccessful signup

  When  I visit the home page
  And I click sign up
  And I press the sign up button

  Then I should see the error message "There was an error creating your account"