# Add an image for the first event, and attach it to all of them

bucket_name = ENV['S3_BUCKET_NAME']
client = Aws::S3::Client.new(region: 'ap-northeast-1')
event_asset_key = "images/events/??????????????.jpg"
event_key = "production/events/??????????????.jpg"
event_image = client.get_object(bucket: bucket_name, key: asset_key)

Event.first.image.attach(key: event_key, io: event_image.body, filename: "??????????????.jpg", content_type: 'image/jpg')

blob = ActiveStorage::Blob.find_by(key: event_key)

Event.all.excluding(Event.first).each do |event|
  event.image.attach(blob)
end

# Add an image for each different (morning) slot, and attach it to all of them

slot_names = TimeSlot.group(:name).count.keys

slot_names.each do |name|
  filename = "#{name.downcase.gsub(' ', '_')}.jpg"
  slot_asset_key = "images/time_slots/#{filename}"
  slot_key = "production/time_slots/#{filename}"
  slot_image = client.get_object(bucket: bucket_name, key: slot_asset_key)

  first_slot = TimeSlot.find_by(name: name)
  first_slot.image.attach(key: slot_key, io: slot_image.body, filename: filename, content_type: 'image/jpg')

  blob = ActiveStorage::Blob.find_by(key: slot_key)

  TimeSlot.where(name: name).excluding(first_slot).each do |slot|
    slot.image.attach(blob)
  end
end