School.create!([
  {
    name: 'オンラインコース'
  },
  {
    name: '田園調布雪谷'
  },
  {
    name: '蒲田駅前'
  },
  {
    name: '東陽町'
  },
  {
    name: '長原'
  },
  {
    name: '門前仲町'
  },
  {
    name: '戸越'
  },
  {
    name: '成城'
  },
  {
    name: '大森'
  },
  {
    name: '早稲田'
  },
  {
    name: 'りんかい東雲'
  },
  {
    name: '新川崎'
  },
  {
    name: '等々力'
  },
  {
    name: '大島'
  },
  {
    name: '三鷹'
  },
  {
    name: '二俣川'
  },
  {
    name: '新浦安'
  },
  {
    name: '天王町'
  },
  {
    name: '南町田グランベリーパーク'
  },
  {
    name: '大井'
  },
  {
    name: '晴海'
  },
  {
    name: '四谷'
  },
  {
    name: '赤羽'
  },
  {
    name: '北品川'
  },
  {
    name: '溝の口'
  },
  {
    name: '矢向'
  },
  {
    name: '南行徳'
  },
  {
    name: '鷺宮'
  },
  {
    name: '馬込'
  },
  {
    name: '大倉山'
  },
  {
    name: '武蔵新城'
  },
  {
    name: '武蔵小杉'
  }
])

飯森エリア = Area.create!(
  name: '飯森エリア'
)

School.where(id: [7, 9, 10, 12, 15, 17, 24, 25, 30, 31]).each do |school|
  飯森エリア.schools << school
end

阿部エリア = Area.create!(
  name: '阿部エリア'
)

School.where(id: [3, 4, 5, 11, 14, 18, 20, 21, 27, 28]).each do |school|
  阿部エリア.schools << school
end

小堀エリア = Area.create!(
  name: '小堀エリア'
)

School.where(id: [6, 8, 13, 16, 19, 22, 23, 26, 29]).each do |school|
  小堀エリア.schools << school
end

田中エリア = Area.create!(
  name: '田中エリア'
)

School.where(id: [32, 33, 34]).each do |school|
  田中エリア.schools << school
end