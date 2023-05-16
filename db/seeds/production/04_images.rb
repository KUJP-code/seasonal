bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')

# Attach the calendar image to the first event
event_asset_key = "images/events/summer_2023.png"
event_key = "production/events/summer_2023.png"
event_image = client.get_object(bucket: bucket_name, key: asset_key)

Event.first.image.attach(key: event_key, io: event_image.body, filename: "summer_2023.png", content_type: 'image/png')
image_blob = ActiveStorage::Blob.find_by(key: event_key)

# Attach the banner image to the first event
banner_asset_key = "images/events/summer_2023_banner.jpg"
banner_key = "production/events/summer_2023_banner.jpg"
banner_image = client.get_object(bucket: bucket_name, key: banner_asset_key)

Event.first.banner.attach(key: banner_key, io: banner_image.body, filename: "summer_2023_banner.jpg", content_type: 'image/jpg')
banner_blob = ActiveStorage::Blob.find_by(key: banner_key)

# Attach calendar images to events at schools other than shin-ura and minami machida
Event.all.excluding(Event.first).each do |event|
  event.image.attach(image_blob) unless different_schools.include?(school.name)

  event.banner
end

# Get the different calendar images
calendar_asset_key = "images/events/summer_2023_food.png"
calendar_key = "production/events/summer_2023_food.png"
calendar_image = client.get_object(bucket: bucket_name, key: calendar_asset_key)
Event.first.image.attach(key: calendar_key, io: calendar_image.body, filename: "summer_2023_food.png", content_type: 'image/png')
calendar_blob = ActiveStorage::Blob.find_by(key: calendar_key)

# Attach the different event images to minami and shin-ura
Event.all.where(name: different_schools).each do |event|
  event.image.attach(calendar_blob)
end

# Add an image for each different (morning) slot, and attach it to all of them

slot_names = TimeSlot.group(:name).count.keys

slot_names.each do |name|
  filename = "#{name}.png"
  slot_asset_key = "images/time_slots/summer_2023/#{filename}"
  slot_key = "production/time_slots/#{filename}"
  slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)

  first_slot = TimeSlot.find_by(name: name)
  first_slot.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/png')

  slot_blob = ActiveStorage::Blob.find_by(key: slot_key)

  TimeSlot.where(name: name).excluding(first_slot).each do |slot|
    slot.image.attach(slot_blob)
  end
end