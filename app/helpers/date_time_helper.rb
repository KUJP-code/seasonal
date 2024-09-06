# frozen_string_literal: true

module DateTimeHelper
  DAYS = {
    'Sunday' => '日',
    'Monday' => '月',
    'Tuesday' => '火',
    'Wednesday' => '水',
    'Thursday' => '木',
    'Friday' => '金',
    'Saturday' => '土'
  }.freeze

  def en_day(date)
    date.strftime('%A')
  end

  def f_time(datetime)
    datetime.strftime('%I:%M%p')
  end

  def ja_date(date)
    date.strftime('%m月%d日') + " #{ja_day(date)}"
  end

  def ja_datetime(datetime)
    "#{ja_date(datetime)} #{f_time(datetime)}"
  end

  def ja_day(date)
    en_day = date.strftime('%A')

    "(#{DAYS[en_day]})"
  end
end
