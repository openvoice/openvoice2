Feature: Choose parallel or round-robin dialling when receiving a call

Scenario: Choosing parallel dialling
  Given that I am logged in
  And I visit my account page

  When I select parallel dialling
  And I update my account

  Then my account should be configured for parallel dialling

Scenario: Choosing round-robin dialling
  Given that I am logged in
  And I visit my account page

  When I select round-robin dialling
  And I update my account

  Then my account should be configured for round-robin dialling
