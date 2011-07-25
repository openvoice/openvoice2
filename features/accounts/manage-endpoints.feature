Feature: Manage the endpoints used in OpenvVoice

Scenario: Add a SIP endpoint to my account
  Given that I am logged in
  And I visit my account page

  When I click add a new endpoint
  And I fill in "Address" with "sip:user@iptel.org"
  And I press "Add"

  Then I should be on my account page
  And I should see the notice "The endpoint has been added to your account"
  And I should see "1" endpoint listed
  And I should see the endpoint "sip:user@iptel.org"