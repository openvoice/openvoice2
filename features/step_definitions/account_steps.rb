When /^I click sign up$/ do
  When 'I click "Sign Up"'
end

When /^I enter my email, password and password confirmation$/ do
  When 'I fill in "Email" with "me@example.com"'
  And 'I fill in "Password" with "password"'
  And 'I fill in "Password confirmation" with "password"'
end

When /^I press the sign up button$/ do
  When 'I press "Sign Up"'
end

Then /^I should see the successful sign up notice$/ do
  has_css?(".notice", :text => "Sign up was successful").should be_true
end