Feature: Make a call from my OpenVoice account

Scenario: Calling a number
  Given that I am logged in
  And I visit my account page
  And I have an endpoint "sip:endpoint@example.com"

  When I click make a call from endpoint "sip:endpoint@example.com"
  And I fill in "To" with "sip:recipient@example.com"
  And I press "Call"

  Then a call should be initiated from "sip:endpoint@example.com" to "sip:recipient@example.com"
  And I should be on my latest call page for "sip:endpoint@example.com"
