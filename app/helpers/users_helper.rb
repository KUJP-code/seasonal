# frozen_string_literal: true

module UsersHelper
  def family_name(user)
    return '' if user.name.nil?

    split_name(user.name).first
  end

  def first_name(user)
    return '' if user.name.nil?

    split_name(user.name).last
  end

  def kana_family(user)
    return '' if user.katakana_name.nil?

    split_name(user.katakana_name).first
  end

  def kana_first(user)
    return '' if user.katakana_name.nil?

    split_name(user.katakana_name).last
  end

  private

  def split_name(name)
    parts = name.to_s.strip.split(/[[:space:]　]+/, 2)
    [parts.first.to_s, parts.second.to_s]
  end
end
