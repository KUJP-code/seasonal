require 'factory_bot_rails'
require 'faker'
# Generate Japanese text
require 'faker/japanese'
Faker::Config.locale = :ja

Dir[Rails.root.join('db/seeds/*.rb')].each do |seed|
  puts "Processing #{seed.split('/').last}..."
  require seed
end
