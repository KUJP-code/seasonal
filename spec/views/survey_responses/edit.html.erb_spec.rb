require 'rails_helper'

RSpec.describe "survey_responses/edit", type: :view do
  before(:each) do
    @survey_response = assign(:survey_response, SurveyResponse.create!(
      :answers => "",
      :child => nil,
      :survey => nil
    ))
  end

  it "renders the edit survey_response form" do
    render

    assert_select "form[action=?][method=?]", survey_response_path(@survey_response), "post" do

      assert_select "input[name=?]", "survey_response[answers]"

      assert_select "input[name=?]", "survey_response[child_id]"

      assert_select "input[name=?]", "survey_response[survey_id]"
    end
  end
end
