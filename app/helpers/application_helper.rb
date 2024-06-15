# frozen_string_literal: true

module ApplicationHelper
  def activity_modifier(activity, child)
    membership_mod = child.external? ? activity.ext_modifier : activity.int_modifier
    level_mod = child.kindy? ? activity.kindy_modifier : activity.ele_modifier
    membership_mod + level_mod
  end

  def date_yy_mm_dd(date)
    date.strftime('%Y年%m月%d日')
  end

  # Needed in both User and Child controllers
  def full_address(user)
    "#{t('.address')}: #{user.prefecture}, #{user.address}, #{user.postcode}"
  end

  def importmap_shim_src
    'https://ga.jspm.io/npm:es-module-shims@1.10.0/dist/es-module-shims.js'
  end
end
