Factory.sequence :email do |n|
  "person#{n}@example.com"
end

Factory.sequence :username do |n|
  "person#{n}"
end

Factory.define(:account) do |f|
  f.email { Factory.create(:email) }
  f.username { Factory.create(:username) }
  f.password "letmein"
  f.password_confirmation "letmein"
end

Factory.define(:endpoint) do |f|
  f.address "sip:user@example.com"
end

Factory.define(:call) do |f|
end