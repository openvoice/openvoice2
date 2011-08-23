Given /^I have an account created$/ do
  Factory(:account, :username => my.username, :email => my.email, :password => my.password)
end

Given /^that I am logged in$/ do
  Given "I have an account created"
  When "I visit the home page"
  And "I enter my email and password"
  And "I press the login button"
end

When /^I click sign up$/ do
  When 'I click "Sign Up"'
end

When /^I click Login$/ do
  When 'I click "Login"'
end

When /^I click Logout$/ do
  When 'I press "Logout"'
end

When /^I enter my email, username, password and password confirmation$/ do
  When 'I fill in "Email" with "'+ my.email + '"'
  And 'I fill in "Username" with "'+ my.username + '"'
  And 'I fill in "Password" with "'+ my.password + '"'
  And 'I fill in "Password confirmation" with "'+ my.password + '"'
end

When /^I press the sign up button$/ do
  When 'I press "Sign Up"'
end

When /^I press the login button$/ do
  When 'I press "Login"'
end

When /^I enter my email and password$/ do
  When 'I fill in "Email" with "' + my.email + '"'
  When 'I fill in "Password" with "' + my.password + '"'
end

When /^I click make a call from endpoint "([^"]*)"$/ do |address|
  endpoint = Endpoint.find_by_address(address)
  When %{I click make a call within "##{dom_id(endpoint)}"}
end

When /^I click make a call$/ do
  When 'I click "Make a Call"'
end

Then /^I should be logged in$/ do
  Then 'I should see "'+ my.email + '"'
end

Then /^I should be logged out$/ do
  Then 'I should see "Login"'
end

Then /^I should see my number$/ do
  Then 'I should see "'+ my.number + '"'
end

When /^I select parallel dialling$/ do
  When 'I check "call all endpoints in parallel"'
end

When /^I select round\-robin dialling$/ do
  When 'I uncheck "call all endpoints in parallel"'
end

When /^I update my account$/ do
  When 'I press "Update"'
end

Then /^my account should be configured for parallel dialling$/ do
  my.account.parallel_dial.should be_true
end

Then /^my account should be configured for round\-robin dialling$/ do
  my.account.parallel_dial.should be_false
end