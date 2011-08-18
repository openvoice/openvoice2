Feature: Make a call from my OpenVoice account

Scenario: Calling a number
  Given that I am logged in
  And I visit my account page
  And I have an endpoint "sip:endpoint@example.com"

  When I click make a call from endpoint "sip:endpoint@example.com"
  And I fill in "Number to call" with "sip:recipient@example.com"
  And I press "Call"

  Then a call should be initiated from "sip:endpoint@example.com" to "sip:recipient@example.com"
  And I should be on my latest call page for "sip:endpoint@example.com"

Scenario: When caller is ringing
  Given that I am logged in
  And I am calling "sip:recipient@example.com" from "sip:endpoint@example.com"
  And the caller "sip:endpoint@example.com" is ringing

  When I visit my latest call page for "sip:endpoint@example.com"
  Then I should see that the caller is ringing

@wip
Scenario: When recipient has answered
  Given that I am logged in
  And I am calling "sip:recipient@example.com" from "sip:endpoint@example.com"
  And the recipient "sip:recipient@example.com" has answered the call

  When I visit my latest call page for "sip:endpoint@example.com"
  Then I should see that the recipient has answered
