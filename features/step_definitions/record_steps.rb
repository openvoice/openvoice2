Given /^I have recorded a greeting$/ do
  my.account.update_attributes(:greeting_path => "http://example.com/assets/greeting-file.mp3")
end

When /^I click record a greeting from endpoint "([^"]*)"$/ do |endpoint|
  When %{I press "Record"}
end

Then /^a call should be initiated from user's openvoice number to "([^"]*)"$/ do |endpoint_address|
  Jobs::RecordGreeting.should have_queued(my.number, endpoint_address)
end

Then /^I should( not)? see the greeting audio player$/ do |inverse|
  if inverse.nil?
    page.should have_css("audio#account-greeting source[src='#{my.account.greeting_path}']")
  else
    page.should_not have_css("audio#account-greeting")
  end
end