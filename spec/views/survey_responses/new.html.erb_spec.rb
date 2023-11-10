require 'rails_helper'

RSpec.describe "survey_responses/new", type: :view do
  before(:each) do
    assign(:survey_response, SurveyResponse.new(
      :answers => "",
      :child => nil,
      :survey => nil
    ))
  end

  it "renders new survey_response form" do
    render

    assert_select "form[action=?][method=?]", survey_responses_path, "post" do

      assert_select "input[name=?]", "survey_response[answers]"

      assert_select "input[name=?]", "survey_response[child_id]"

      assert_select "input[name=?]", "survey_response[survey_id]"
    end
  end
end
