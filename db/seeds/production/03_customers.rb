30.times do |i|
  User.create!(
    first_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    family_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    kana_first: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    kana_family: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
    email: "#{i}@gmail.com",
    password: 'mashedpotatoessssss',
    postcode: '216-0011',
    address: 'pizza',
    prefecture: '東京都',
    phone: '07042159870'
  )
end

