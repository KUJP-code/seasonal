# frozen_string_literal: true

module ApplicationHelper
  RECRUIT_HISTORY_FIELD_LABELS = %w[
    role email phone full_name date_of_birth full_address gender highest_education
    employment_history reason_for_application nationality work_visa_status questions
    tracking_link_slug contacted_on interviewed hr_comments
  ].freeze

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

  def recruit_change_entries(version)
    JSON.parse(version.object_changes || '{}')
        .slice(*RECRUIT_HISTORY_FIELD_LABELS)
        .map do |field, values|
      {
        field: recruit_change_field_label(field),
        from: recruit_change_value_label(values[0], field),
        to: recruit_change_value_label(values[1], field)
      }
    end
  rescue JSON::ParserError
    []
  end

  def recruit_version_actor(version)
    return t('recruit_applications.show.system_change') if version.whodunnit.blank?

    User.find_by(id: version.whodunnit)&.name || t('recruit_applications.show.deleted_user')
  end

  private

  def recruit_change_field_label(field)
    I18n.t("recruit_applications.show.#{field}", default: field.to_s.humanize)
  end

  def recruit_change_value_label(value, field)
    return t('recruit_applications.show.blank_value') if value.blank?

    case field.to_s
    when 'interviewed'
      value ? t('recruit_applications.show.yes') : t('recruit_applications.show.no')
    when 'contacted_on', 'date_of_birth'
      I18n.l(Date.parse(value.to_s))
    else
      value.to_s
    end
  rescue ArgumentError
    value.to_s
  end
end
