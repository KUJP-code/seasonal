Area.first.schools.create!([
  {
    name: "大倉山",
    address: "〒222-0032 神奈川県横浜市港北区大豆戸町80",
    phone: '0120378056'
  },
  {
    name: "武蔵小杉",
    address: "〒211-0016 神奈川県川崎市中原区市ノ坪232",
    phone: '0120378056'
  },
  {
    name: "溝の口",
    address: "〒213-0002 神奈川県川崎市高津区二子３丁目３３−20 カーサ・フォーチュナー",
    phone: '0120378056'
  }
])

School.all.last.managers << User.find_by(role: 'school_manager')

puts 'Added 3 schools and gave each a manager'