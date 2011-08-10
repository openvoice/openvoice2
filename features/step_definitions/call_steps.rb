Then /^a call should be initiated from "(.*)" to "(.*)"$/ do |caller, recipient|
  assert_queued Jobs::OutgoingCall, [caller, recipient]
end