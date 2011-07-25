When /^I click add a new endpoint$/ do
  When 'I click "Add a new endpoint"'
end

Then /^I should see "([^"]*)" endpoint listed$/ do |count|
  all(".endpoint").size.should eq count.to_i
end

Then /^I should see the endpoint "([^"]*)"$/ do |address|
  has_css?(".endpoint", :text => address)
end