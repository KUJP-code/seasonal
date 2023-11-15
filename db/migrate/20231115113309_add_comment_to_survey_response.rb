class AddCommentToSurveyResponse < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_responses, :comment, :string
  end
end
