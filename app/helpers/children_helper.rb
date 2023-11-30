# frozen_string_literal: true

module ChildrenHelper
  def kanji_category(category)
    case category
    when 'internal'
      '通学生'
    when 'reservation'
      '予約生'
    else
      '非会員'
    end
  end

  def parent_link(parent)
    return 'なし' if parent.nil?

    link_to parent.name, user_path(parent)
  end
end
