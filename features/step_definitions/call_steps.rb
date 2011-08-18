Given /^I am calling "([^"]*)" from "([^"]*)"$/ do |recipient, caller|
  Given %{I have an endpoint "#{caller}"}
  When %{I click make a call from endpoint "#{caller}"}
  And %{I fill in "Number to call" with "#{recipient}"}
  And %{I press "Call"}
end

Given /^the caller "(.*)" is ringing$/ do |caller|
  Endpoint.find_by_address(caller).calls.last.update_attributes(:state => :caller_ringing)
end

Given /^the recipient "([^"]*)" has answered the call$/ do |recipient|
  Call.find_by_recipient_address(recipient).update_attributes(:state => :recipient_answered)
end

Then /^I should see that the caller is ringing$/ do
  page.should have_content("Caller ringing")
end

Then /^I should see that the recipient has answered$/ do
  page.should have_content("Recipient answered")
end

Then /^a call should be initiated from "(.*)" to "(.*)"$/ do |caller, recipient|
  endpoint = Endpoint.find_by_address(caller)
  Jobs::OutgoingCall.should have_queued(Call.find_by_recipient_address_and_endpoint_id(recipient, endpoint.id).id)
end