# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |origin, _env|
      Rails.configuration.x.rashimba_origins.include?(origin)
    end
    resource '/api/rashimba/sponsor_inquiries',
             headers: %w[Content-Type], methods: %i[post options]
    resource '/api/rashimba/release_notifications',
             headers: %w[Content-Type], methods: %i[post options]
  end

  allow do
    origins '*'
    resource '/gas_schools', headers: :any, methods: %i[get]
    resource '/gas_inquiries', headers: :any, methods: %i[get post]
    resource '/gas_update', headers: :any, methods: %i[post]
    resource '/schools', headers: :any, methods: %i[post]
    resource '/setsu_schools.json', headers: :any, methods: %i[get]
    resource '/create_inquiry.json', headers: :any, methods: %i[post]
    resource '/api/recruit_applications', headers: :any, methods: %i[post]
    resource '/api/login', headers: :any, methods: %i[post]
    resource '/api/pictures', headers: :any, methods: %i[get]
    resource '/api/seasonal-pictures', headers: :any, methods: %i[post]
  end
end
