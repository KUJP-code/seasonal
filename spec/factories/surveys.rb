# frozen_string_literal: true

FactoryBot.define do
  factory :survey do
    name { 'Test Survey' }
    questions do
      [{ 'text' => 'checkbox', 'options' => 'a, b, c', 'input_type' => 'checkbox' },
       { 'text' => 'date', 'options' => '', 'input_type' => 'date' },
       { 'text' => 'datetime', 'options' => '', 'input_type' => 'datetime-local' },
       { 'text' => 'email', 'options' => '', 'input_type' => 'email' },
       { 'text' => 'number', 'options' => '', 'input_type' => 'number' },
       { 'text' => 'radio', 'options' => '1, 2, 3', 'input_type' => 'radio' },
       { 'text' => 'select', 'options' => 'opt1, opt2, opt3', 'input_type' => 'select' },
       { 'text' => 'txt', 'options' => '', 'input_type' => 'text' },
       { 'text' => 'textarea', 'options' => '', 'input_type' => 'textarea' },
       { 'text' => 'time', 'options' => '', 'input_type' => 'time' }]
    end
    criteria { {} }

    factory :active_survey do
      active { true }

      factory :criterialess_survey do
        criteria { Child.column_names.index_with { |_col| '' } }
      end
    end
  end
end
