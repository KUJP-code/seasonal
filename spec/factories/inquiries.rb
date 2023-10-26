FactoryBot.define do
  factory :inquiry do
    setsumeikai { nil }
    parent_name { "MyString" }
    phone { "MyString" }
    email { "MyString" }
    child_name { "MyString" }
    child_birthday { "2023-10-26" }
    kindy { "MyString" }
    ele_school { "MyString" }
    planned_school { "MyString" }
    start_date { "2023-10-26" }
  end
end
