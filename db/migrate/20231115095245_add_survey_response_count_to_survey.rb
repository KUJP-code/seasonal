class AddSurveyResponseCountToSurvey < ActiveRecord::Migration[7.0]
  def change
    add_column :surveys, :survey_responses_count, :integer, default: 0
  end
end
