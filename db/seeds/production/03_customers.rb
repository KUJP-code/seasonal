School.all.each do |school|
  20.times do |i|
    school.customers.create!(
      first_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
      family_name: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
      kana_first: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
      kana_family: %w[Timmy Sally Billy Sarah Brett ヨシ マリナ カイト].sample,
      email: "#{school.name}#{i}@gmail.com",
      password: 'mashedpotatoessssss',
      postcode: '216-0011',
      address: 'pizza',
      prefecture: '東京都',
      phone: '07042159870'
    )
  end
end
