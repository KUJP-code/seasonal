# frozen_string_literal: true

RSpec::Matchers.define :include_all do |string_array|
  match do |actual|
    @errors = string_array.reject { |string| actual.include?(string) }
    @errors.empty?
  end

  failure_message do
    "#{actual} did not include: #{@errors.join(', ')}"
  end

  failure_message_when_negated do
    "#{actual} included: #{@errors.join(', ')}"
  end

  description do
    "includes: #{string_array.join(', ')}"
  end
end
