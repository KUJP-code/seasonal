Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource 'gas_schools', headers: :any, methods: %i[get]
    resource 'gas_inquiries', headers: :any, methods: %i[get post]
    resource 'gas_update_sent', headers: :any, methods: %i[post]
    resource 'schools', headers: :any, methods: %i[get post]
  end
end
