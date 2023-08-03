Event.all.each do |event|
  event.options.create!(
    name: 'フォトサービス',
    category: :event,
    cost: 1_100
  )
end

puts 'Added the photo service option to each event'

Event.all.each do |event|
  event.time_slots.morning.find_each(batch_size: 100) do |m_slot|
    m_slot.options.create!([
      {
        name: '昼食',
        category: :meal,
        cost: 660
      },
      {
        name: 'なし',
        category: :arrival,
        modifier: 0,
        cost: 0
      },
      {
        name: '9:30~（1コマ）',
        category: :arrival,
        modifier: -30,
        cost: 460
      },
      {
        name: '9:00~（2コマ）',
        category: :arrival,
        modifier: -60,
        cost: 920
      },
      {
        name: '8:30~（3コマ）',
        category: :arrival,
        modifier: -90,
        cost: 1_380
      },
      {
        name: 'なし',
        category: :k_arrival,
        modifier: 0,
        cost: 0
      },
      {
        name: '9:30~（1コマ）',
        category: :k_arrival,
        modifier: -30,
        cost: 580
      },
      {
        name: '9:00~（2コマ）',
        category: :k_arrival,
        modifier: -60,
        cost: 1_160
      },
      {
        name: '8:30~（3コマ）',
        category: :k_arrival,
        modifier: -90,
        cost: 1_740
      }
    ])
  end

  event.time_slots.afternoon.find_each(batch_size: 100) do |a_slot|
    a_slot.options.create!([
      {
        name: '夕食',
        category: :meal,
        cost: 660
      },
      {
        name: 'なし',
        category: :departure,
        modifier: 0,
        cost: 0
      },
      {
        name: '~19:00（1コマ）',
        category: :departure,
        modifier: 30,
        cost: 460
      },
      {
        name: '~19:30（2コマ）',
        category: :departure,
        modifier: 60,
        cost: 920
      },
      {
        name: '~20:00（3コマ）',
        category: :departure,
        modifier: 90,
        cost: 1_380
      },
      {
        name: '~20:30（4コマ）',
        category: :departure,
        modifier: 120,
        cost: 1_840
      },
      {
        name: 'なし',
        category: :k_departure,
        modifier: 0,
        cost: 0
      },
      {
        name: '~19:00（1コマ）',
        category: :k_departure,
        modifier: 30,
        cost: 580
      },
      {
        name: '~19:30（2コマ）',
        category: :k_departure,
        modifier: 60,
        cost: 1_160
      },
      {
        name: '~20:00（3コマ）',
        category: :k_departure,
        modifier: 90,
        cost: 1_740
      },
      {
        name: '~20:30（4コマ）',
        category: :k_departure,
        modifier: 120,
        cost: 2_320
      }
    ])
  end
  
  event.time_slots.morning.where(category: :special).each do |sp_slot|
    sp_slot.options.create!([
      {
        name: '中延長',
        category: :extension,
        cost: 1_380
      },
      {
        name: '中延長',
        category: :k_extension,
        cost: 1_740
      }
    ])
  end
end

puts 'Created options for Summer school'