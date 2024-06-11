# frozen_string_literal: true

module ChildrenHelper
  def child_categories
    forbidden = %w[default unknown]
    Child.categories.keys.reject { |k| forbidden.include?(k) }
         .map { |k| [t(".#{k}"), k] }
  end

  def child_photos
    forbidden = %w[マイページOK Unknown]
    Child.photos.keys.reject { |k| forbidden.include?(k) }
  end

  def child_primary_grades
    Child.grades.keys[3..11].map { |k| [k, k] }
  end

  def family_name(child)
    return '' if child.name.nil?

    child.name.split.first
  end

  def first_name(child)
    return '' if child.name.nil?

    child.name.split.last
  end

  def kana_family(child)
    return '' if child.name.nil?

    child.katakana_name.split.first
  end

  def kana_first(child)
    return '' if child.name.nil?

    child.katakana_name.split.last
  end

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
