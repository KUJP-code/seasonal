# frozen_string_literal: true

module ApplicationHelper
  def date_yy_mm_dd(date)
    date.strftime('%Y年%m月%d日')
  end

  # Needed in both User and Child controllers
  def full_address(user)
    "#{t('.address')}: #{user.prefecture}, #{user.address}, #{user.postcode}"
  end
end
