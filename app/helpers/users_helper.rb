# frozen_string_literal: true

module UsersHelper
  def family_name(user)
    return '' if user.name.nil?

    user.name.split.first
  end

  def first_name(user)
    return '' if user.name.nil?

    user.name.split.last
  end

  def kana_family(user)
    return '' if user.name.nil?

    user.katakana_name.split.first
  end

  def kana_first(user)
    return '' if user.name.nil?

    user.katakana_name.split.last
  end
end
