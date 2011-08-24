Feature: Record a greeting for my OpenVoice account

Scenario: Record a greeting
  Given that I am logged in
  And I visit my account page
  And I have an endpoint "sip:endpoint@example.com"
  When I click record a greeting from endpoint "sip:endpoint@example.com"
  Then a call should be initiated from user's openvoice address to "sip:endpoint@example.com"
