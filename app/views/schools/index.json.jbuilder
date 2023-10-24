# frozen_string_literal: true

json.array! @schools do |s|
  json.id s.id.to_s
  json.name s.name
  json.address s.address
  json.phone s.phone
  json.bus_areas s.details['bus_areas']
  json.nearby_stations s.details['nearby_stations']
end
