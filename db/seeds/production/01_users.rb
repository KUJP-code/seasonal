# Creates my test accounts

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
    role: :area_manager,
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
    role: :school_manager,
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
    role: :customer,
    postcode: '216-0011',
    address: 'pizza',
    prefecture: '東京都',
    phone: '07042159870'
  }
])

User.find_by(role: 'area_manager').managed_areas.create!(name: '神奈川県')