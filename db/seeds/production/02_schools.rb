Area.create!([
  {
    name: '飯森エリア'
  },
  {
    name: '阿部エリア'
  },
  {
    name: '小堀エリア'
  },
  {
    name: '田中エリア'
  }
])

School.create!([
  {
    name: 'オンラインコース',
    area: Area.find_by(name: "Test Area")
  },
  {
    name: '田園調布雪谷',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '蒲田駅前',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '東陽町',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '長原',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '門前仲町',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '戸越',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '成城',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '大森',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '早稲田',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: 'りんかい東雲',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '新川崎',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '等々力',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '大島',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '三鷹',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '二俣川',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '新浦安',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '天王町',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '南町田グランベリーパーク',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '大井',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '晴海',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '四谷',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '赤羽',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '北品川',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '溝の口',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '矢向',
    area: Area.find_by(name: '阿部エリア')
  },
  {
    name: '南行徳',
    area: Area.find_by(name: '小堀エリア')
  },
  {
    name: '鷺宮',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '馬込',
    area: Area.find_by(name: '飯森エリア')
  },
  {
    name: '大倉山',
    area: Area.find_by(name: '田中エリア')
  },
  {
    name: '武蔵新城',
    area: Area.find_by(name: '田中エリア')
  },
  {
    name: '武蔵小杉',
    area: Area.find_by(name: '田中エリア')
  }
])
