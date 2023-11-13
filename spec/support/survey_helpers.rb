# frozen_string_literal: true

module SurveyHelpers
  def set_random_boolean_criteria
    col = %w[first_seasonal kindy received_hat].sample
    value = [true, false].sample
    { col => value }
  end

  def set_random_enum_criteria
    col = %w[category grade photos].sample
    value = Child.send(col.pluralize).keys.reject { |k| k == 'default' }.sample
    { col => value }
  end

  def set_random_string_criteria
    col = %w[allergies ele_school_name en_name katakana_name name].sample
    value = Faker::Name.name.kana
    { col => value }
  end

  def set_single_criteria(child, criteria)
    child.update(criteria.keys.first => criteria.values.last)
    create(:active_survey, criteria: criteria)
  end
end
