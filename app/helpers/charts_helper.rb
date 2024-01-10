# frozen_string_literal: true

module ChartsHelper
  def school_name(nav_schools, school_id)
    t("schools.#{nav_schools.find { |s| s.id == school_id }.name}")
  end
end
