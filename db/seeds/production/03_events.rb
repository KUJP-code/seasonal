School.all.each do |school|
  school.events.create!(
    name: 'Summer School',
    start_date: 'July 20 2023',
    end_date: 'August 31 2023',
    member_prices_id: 1,
    non_member_prices_id: 2,
    goal: 100_000_000
  )
end

# Create the slots every event has
Event.all.each do |event|
  event.time_slots.create!([
    {
      name: 'カラフルテープアート',
      morning: true,
      start_time: '20 July 2023 10:00 JST +09:00',
      end_time: '20 July 2023 13:30 JST +09:00'
    },
    {
      name: 'ピクチャーキーホルダー',
      morning: true,
      start_time: '21 July 2023 10:00 JST +09:00',
      end_time: '21 July 2023 13:30 JST +09:00'
    },
    {
      name: '冒険者のクエスト！',
      morning: true,
      start_time: '24 July 2023 10:00 JST +09:00',
      end_time: '24 July 2023 13:30 JST +09:00'
    },
    {
      name: 'ウォーターベースボール(7月25日)',
      morning: true,
      start_time: '25 July 2023 10:00 JST +09:00',
      end_time: '25 July 2023 13:30 JST +09:00'
    },
    {
      name: '忍者になろう！',
      morning: true,
      start_time: '26 July 2023 10:00 JST +09:00',
      end_time: '26 July 2023 13:30 JST +09:00'
    },
    {
      name: 'フルーシスムージー★',
      morning: true,
      start_time: '27 July 2023 10:00 JST +09:00',
      end_time: '27 July 2023 13:30 JST +09:00'
    },
    {
      name: '世界のゲームを体験しよう',
      morning: true,
      start_time: '28 July 2023 10:00 JST +09:00',
      end_time: '28 July 2023 13:30 JST +09:00'
    },
    {
      name: '水鉄砲合＆スイカ割り！',
      morning: true,
      start_time: '29 July 2023 10:00 JST +09:00',
      end_time: '29 July 2023 13:30 JST +09:00',
      category: :special
    },
    {
      name: 'サボテンクラフト',
      morning: true,
      start_time: '31 July 2023 10:00 JST +09:00',
      end_time: '31 July 2023 13:30 JST +09:00'
    },
    {
      name: 'ハワイアンかき氷',
      morning: true,
      start_time: '1 August 2023 10:00 JST +09:00',
      end_time: '1 August 2023 13:30 JST +09:00'
    },
    {
      name: '水鉄砲合戦!!(8月2日)',
      morning: true,
      start_time: '2 August 2023 10:00 JST +09:00',
      end_time: '2 August 2023 13:30 JST +09:00'
    },
    {
      name: '海のスライム',
      morning: true,
      start_time: '4 August 2023 10:00 JST +09:00',
      end_time: '4 August 2023 13:30 JST +09:00'
    },
    {
      name: 'Kids Up★ゲームセンター',
      morning: true,
      start_time: '7 August 2023 10:00 JST +09:00',
      end_time: '7 August 2023 13:30 JST +09:00'
    },
    {
      name: '水鉄砲合戦!!(8月8日)',
      morning: true,
      start_time: '8 August 2023 10:00 JST +09:00',
      end_time: '8 August 2023 13:30 JST +09:00'
    },
    {
      name: 'オリジナルバッグ作り',
      morning: true,
      start_time: '16 August 2023 10:00 JST +09:00',
      end_time: '16 August 2023 13:30 JST +09:00'
    },
    {
      name: 'デザートスライム',
      morning: true,
      start_time: '17 August 2023 10:00 JST +09:00',
      end_time: '17 August 2023 13:30 JST +09:00'
    },
    {
      name: 'ウォーターゲーム対決！',
      morning: true,
      start_time: '18 August 2023 10:00 JST +09:00',
      end_time: '18 August 2023 13:30 JST +09:00'
    },
    {
      name: '水鉄砲合戦!!(8月21日)',
      morning: true,
      start_time: '21 August 2023 10:00 JST +09:00',
      end_time: '21 August 2023 13:30 JST +09:00'
    },
    {
      name: 'バンダナの絞り染め',
      morning: true,
      start_time: '22 August 2023 10:00 JST +09:00',
      end_time: '22 August 2023 13:30 JST +09:00'
    },
    {
      name: '暗闇で光るスライム',
      morning: true,
      start_time: '23 August 2023 10:00 JST +09:00',
      end_time: '23 August 2023 13:30 JST +09:00'
    },
    {
      name: 'DIY水族館',
      morning: true,
      start_time: '24 August 2023 10:00 JST +09:00',
      end_time: '24 August 2023 13:30 JST +09:00'
    },
    {
      name: '貝殻ペンダント',
      morning: true,
      start_time: '25 August 2023 10:00 JST +09:00',
      end_time: '25 August 2023 13:30 JST +09:00'
    },
    {
      name: 'ウォーターベースボール(8月28日)',
      morning: true,
      start_time: '28 August 2023 10:00 JST +09:00',
      end_time: '28 August 2023 13:30 JST +09:00'
    },
    {
      name: 'レインボーキーホルダー',
      morning: true,
      start_time: '29 August 2023 10:00 JST +09:00',
      end_time: '29 August 2023 13:30 JST +09:00'
    },
    {
      name: 'ビーチジオラマ',
      morning: true,
      start_time: '30 August 2023 10:00 JST +09:00',
      end_time: '30 August 2023 13:30 JST +09:00'
    }
  ])
end

# Create the different slots for normal schools
different_schools = %w[新浦安 南町田グランベリーパーク]

School.all.where.not(name: different_schools).each do |school|
  school.events.first.time_slots.create!([
    {
      name: 'ペーパーランタン',
      morning: true,
      start_time: '3 August 2023 10:00 JST +09:00',
      end_time: '3 August 2023 13:30 JST +09:00'
    },
    {
      name: 'オレオシェイク',
      morning: true,
      start_time: '9 August 2023 10:00 JST +09:00',
      end_time: '9 August 2023 13:30 JST +09:00'
    },
    {
      name: 'アイスクリーム屋さん',
      morning: true,
      start_time: '31 August 2023 10:00 JST +09:00',
      end_time: '31 August 2023 13:30 JST +09:00'
    }
  ])
end

# Create the different slots for Minami-machida and Shin-Urayasu
School.all.where(name: different_schools).each do |school|
  school.events.first.time_slots.create!([
    {
      name: '焼きそばを作ろう',
      morning: true,
      start_time: '3 August 2023 10:00 JST +09:00',
      end_time: '3 August 2023 13:30 JST +09:00'
    },
    {
      name: 'アメリカン★ホットドッグ',
      morning: true,
      start_time: '9 August 2023 10:00 JST +09:00',
      end_time: '9 August 2023 13:30 JST +09:00'
    },
    {
      name: 'フレンチクレープ',
      morning: true,
      start_time: '31 August 2023 10:00 JST +09:00',
      end_time: '31 August 2023 13:30 JST +09:00'
    }
  ])
end

# Create all afternoon slots
Event.all.each do |event|
  event.time_slots.morning.each do |slot|
    # Make sure the afternoon of the special day gets its own name
    name = slot.special? ? '巨大なお城のクラフト＆アイスクリーム屋さん' : slot.name
    slot.create_afternoon_slot(
      name: name,
      start_time: slot.start_time + 5.hours,
      end_time: slot.end_time + 5.hours,
      category: slot.category,
      morning: false,
      event_id: slot.event_id
    )
  end
  puts "#{event.name} at #{event.school.name} done"
end
