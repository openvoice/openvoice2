Factory.define(:account) do |f|
  f.email "me@example.com"
  f.password "letmein"
  f.password_confirmation "letmein"
end

Factory.define(:endpoint) do |f|
  f.address "sip:user@example.com"
end