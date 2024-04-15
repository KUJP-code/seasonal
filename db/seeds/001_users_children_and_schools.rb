# Create my test accounts

admin = FactoryBot.create(
  :user, email: 'admin@gmail.com', password: 'adminadminadmin',
         role: :admin, pin: '0000'
)

am = FactoryBot.create(
  :user, email: 'am@gmail.com', password: 'ampasswordampassword',
         role: :area_manager, pin: '0000'
)

sm = FactoryBot.create(
  :user, email: 'sm@gmail.com', password: 'smpasswordsmpassword',
         role: :school_manager, pin: '0000'
)

customer = FactoryBot.create(
  :user, email: 'customer@gmail.com', password: 'customerpassword',
         role: :customer
)

puts 'Created test accounts'

area = Area.create!(name: '中川')

Area.first.schools.create!(
  [{ name: 'Test', area_id: area.id }, { name: 'オンラインコース', area_id: area.id },
   { name: '田園調布雪谷', area_id: area.id }, { name: '蒲田駅前', area_id: area.id },
   { name: '東陽町', area_id: area.id }, { name: '池上', area_id: area.id }, { name: '長原', area_id: area.id },
   { name: '門前仲町', area_id: area.id }, { name: '戸越', area_id: area.id },
   { name: '成城', area_id: area.id }, { name: '大森', area_id: area.id }, { name: '早稲田', area_id: area.id },
   { name: 'りんかい東雲', area_id: area.id }, { name: '新川崎', area_id: area.id },
   { name: '等々力', area_id: area.id }, { name: '大島', area_id: area.id }, { name: '三鷹', area_id: area.id },
   { name: '二俣川', area_id: area.id }, { name: '新浦安', area_id: area.id }, { name: '天王町', area_id: area.id },
   { name: '南町田グランベリーパーク', area_id: area.id }, { name: '大井', area_id: area.id },
   { name: '晴海', area_id: area.id }, { name: '四谷', area_id: area.id }, { name: '赤羽', area_id: area.id },
   { name: '北品川', area_id: area.id }, { name: '溝の口', area_id: area.id }, { name: '矢向', area_id: area.id },
   { name: '南行徳', area_id: area.id }, { name: '鷺宮', area_id: area.id }, { name: '馬込', area_id: area.id },
   { name: '大倉山', area_id: area.id }, { name: '武蔵新城', area_id: area.id }, { name: '武蔵小杉', area_id: area.id },
   { name: '川口', area_id: area.id }, { name: '池袋', area_id: area.id }]
)

en_names = %w[Timmy Sally Billy Sarah Viktoria Brett Leroy]

School.all.each do |school|
  parents = FactoryBot.create_list(:user, 5, role: :customer)
  parents.each do |parent|
    parent.children.create!(
      FactoryBot.attributes_for(:child, en_name: en_names.sample, photos: 'OK',
                                        school_id: school.id, category: :internal,
                                        first_seasonal: false, received_hat: true)
    )
    parent.children.create!(
      FactoryBot.attributes_for(:child, en_name: en_names.sample, photos: 'NG',
                                        school_id: school.id, category: :external,
                                        first_seasonal: true, received_hat: false)
    )
  end
  sm = FactoryBot.create(:user, password: 'schoolschool', name: "#{school.name}",
                                role: :school_manager)
  school.managers << sm
end

User.find_by(role: 'area_manager').managed_areas << Area.last
School.find_by(name: '大倉山').managers << User.find_by(role: 'school_manager')

puts 'Created schools and their users'
