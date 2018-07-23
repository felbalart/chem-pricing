FactoryGirl.define do
  factory :tax_rule do
    tax_type "MyString"
    customer nil
    product nil
    origin "MyString"
    destination "MyString"
    value "9.99"
    upload
  end
end
