Then /^a call should be initiated from "(.*)" to "(.*)"$/ do |caller, recipient|
  endpoint = Endpoint.find_by_address(caller)
  Jobs::OutgoingCall.should have_queued(Call.find_by_recipient_address_and_endpoint_id(recipient, endpoint.id).id)
end