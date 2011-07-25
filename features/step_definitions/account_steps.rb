Given /^I have an account created$/ do
  my.account = Factory(:account)
end

When /^I click sign up$/ do
  When 'I click "Sign Up"'
end

When /^I click Login$/ do
  When 'I click "Login"'
end

When /^I enter my email, password and password confirmation$/ do
  When 'I fill in "Email" with "'+ my.email + '"'
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

Then /^I should be logged in$/ do
  Then 'I should see "'+ my.email + '"'
end