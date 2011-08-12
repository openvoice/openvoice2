Then /^a call should be initiated from "(.*)" to "(.*)"$/ do |caller, recipient|
  account = Endpoint.find_by_address(caller).account
  assert_queued Jobs::OutgoingCall, [caller, recipient, account.number]
end