# frozen_string_literal: true

Rails.application.config.x.rashimba_origins = ENV.fetch(
  'RASHIMBA_ALLOWED_ORIGINS', 'https://rashimba.com,https://www.rashimba.com'
).split(',').map(&:strip).reject(&:blank?).freeze
