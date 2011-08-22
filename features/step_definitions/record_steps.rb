When /^I click record a greeting from endpoint "([^"]*)"$/ do |endpoint|
  When %{I press "Record"}
end

Then /^a call should be initiated from user's openvoice number to "([^"]*)"$/ do |endpoint_address|
  Jobs::RecordGreeting.should have_queued(my.number, endpoint_address)
end