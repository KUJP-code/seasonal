Event.all.each do |event|
  event.options.create!(
    name: 'Photo Service',
    description: "Capture your children's treasured memories!",
    category: :event,
    cost: 3000
  )
end

puts 'Added the photo service option to each event'

Event.where(name: 'Spring School 2023').each do |event|
  event.time_slots.each do |slot|
    slot.options.create!([
      {
        name: 'Arrive on time',
        category: :arrival,
        modifier: 0,
        description: 'Be normal!',
        cost: 0
      },
      {
        name: 'Arrive 30min early',
        category: :arrival,
        modifier: -30,
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Arrive 1hr early',
        category: :arrival,
        modifier: -60,
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Leave on time',
        category: :departure,
        modifier: 0,
        description: 'Be normal!',
        cost: 0
      },
      {
        name: 'Leave 30min late',
        category: :departure,
        modifier: +30,
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
      {
        name: 'Leave 1hr late',
        category: :departure,
        modifier: +60,
        description: 'Be at KU longer, for even more fun!',
        cost: 100
      },
    ])
    slot.image.attach(io: File.open("app/assets/images/#{slot.name.downcase.gsub(' ', '_').gsub('_pm', '')}.jpg"), filename: 'logo.jpg', content_type: 'image/jpg')
  end

  event.time_slots.morning.each do |m_slot|
    m_slot.options.create!(
    name: '昼',
    description: 'Top up on energy through the day!',
    category: :meal,
    cost: 100
    )
  end

  event.time_slots.afternoon.each do |a_slot|
    a_slot.options.create!(
    name: '晩',
    description: 'Top up on energy through the day!',
    category: :meal,
    cost: 100
    )
  end
  
  event.time_slots.morning.where(category: :special).each do |sp_slot|
    sp_slot.options.create!(
      name: '中延長',
      description: 'Spend the whole day with friends!',
      category: :extension,
      cost: 100
      )
  end
end

puts 'Created options for spring school, and added images to slots'
