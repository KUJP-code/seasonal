User.create!([
  {
    email: 'live_admin@gmail.com',
    password: ENV['ADMIN_PASS'],
    first_name: 'Brett',
    family_name: 'Tanner',
    kana_first: 'ブレット',
    kana_family: 'ターナー',
    role: :admin,
    postcode: '216-0011',
    address: 'pizza',
    prefecture: '東京都',
    phone: '07042159870'
  },
  {
    email: 'live_am@gmail.com',
    password: ENV['AM_PASS'],
    first_name: 'Leroy',
    family_name: 'Harrison',
    kana_first: 'レオロイ',
    kana_family: 'ハッリソン',
    role: :admin,
    postcode: '216-0011',
    address: 'pizza',
    prefecture: '東京都',
    phone: '07042159870'
  },
  {
    email: 'live_sm@gmail.com',
    password: ENV['SM_PASS'],
    first_name: 'Yoshi',
    family_name: 'Minoru',
    kana_first: 'ヨシ',
    kana_family: 'ミノル',
    role: :admin,
    postcode: '216-0011',
    address: 'pizza',
    prefecture: '東京都',
    phone: '07042159870'
  },
  {
    email: 'live_customer@gmail.com',
    password: ENV['CUSTOMER_PASS'],
    first_name: 'Jack',
    family_name: 'Hann',
    kana_first: 'ジャク',
    kana_family: 'ハン',
    role: :admin,
    postcode: '216-0011',
    address: 'pizza',
    prefecture: '東京都',
    phone: '07042159870'
  }
])

User.find_by(role: 'area_manager').managed_areas.create!(name: '神奈川県')

non_member = User.create!(
  email: 'non_member@gmail.com',
  password: 'nonmembernon',
  first_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  family_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  kana_first: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  kana_family: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  role: :customer,
  postcode: '216-0011',
  address: 'pizza',
  prefecture: '東京都',
  phone: '07042159870'
  school: School.all.last
)

non_member.children.create!([
{
  first_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  family_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  kana_first: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  kana_family: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
  birthday: 'Fri, 21 Aug 2020',
  ssid: "#{customer.id}#{customer.school_id}2".to_i,
  ele_school_name: '菊名',
  allergies: '',
  grade: '年中',
  category: :external,
  school: non_member.school
},
{
  first_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  family_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  kana_first: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  kana_family: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
  birthday: 'Fri, 21 Aug 2020',
  ssid: "#{customer.id}#{customer.school_id}2".to_i,
  ele_school_name: '菊名',
  post_photos: true,
  allergies: '',
  grade: '小４',
  category: :external,
  school: non_member.school
}
])

member = User.create!(
  email: 'member@gmail.com',
  password: 'membermembermember',
  first_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  family_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  kana_first: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  kana_family: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
  role: :customer,
  postcode: '216-0011',
  address: 'pizza',
  prefecture: '東京都',
  phone: '07042159870'
  school: School.all.last
)

member.children.create!([
  {
    first_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    family_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    kana_first: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    kana_family: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
    birthday: 'Fri, 21 Aug 2020',
    ssid: "#{customer.id}#{customer.school_id}2".to_i,
    ele_school_name: '菊名',
    post_photos: true,
    needs_hat: false,
    allergies: 'milk',
    grade: '年中',
    category: 'internal',
    school: member.school
  },
  {
    first_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    family_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    kana_first: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    kana_family: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    en_name: %w[Timmy Sally Billy Sarah Viktoria Brett].sample,
    birthday: 'Fri, 21 Aug 2020',
    ssid: "#{customer.id}#{customer.school_id}2".to_i,
    ele_school_name: '菊名',
    needs_hat: false,
    allergies: 'milk',
    grade: '小４',
    category: 'internal',
    school: member.school
  }
])

member.children.each do |child|
child.create_regular_schedule!(
  monday: true,
  tuesday: false,
  wednesday: true,
  thursday: false,
  friday: false
)
end

puts 'Created test users for only member children and only non-member children, with no registrations'