organization = Organization.find_or_create_by!(name: "Acme Corp")

downtown = organization.sites.find_or_create_by!(name: "Downtown Campus")
tower = downtown.buildings.find_or_create_by!(name: "Tower 1") { |b| b.timezone = "America/Chicago" }
lobby_floor = tower.floors.find_or_create_by!(name: "1")
penthouse = tower.floors.find_or_create_by!(name: "Penthouse")
summit = penthouse.rooms.find_or_create_by!(name: "Summit")
everest = penthouse.rooms.find_or_create_by!(name: "Everest")
penthouse.rooms.find_or_create_by!(name: "Kilimanjaro")
penthouse.rooms.find_or_create_by!(name: "Denali")
lobby_floor.rooms.find_or_create_by!(name: "Lobby")
lobby_floor.rooms.find_or_create_by!(name: "Board Room")

westside = organization.sites.find_or_create_by!(name: "Westside Office")
annex = westside.buildings.find_or_create_by!(name: "Annex") { |b| b.timezone = "America/Los_Angeles" }
annex_floor = annex.floors.find_or_create_by!(name: "2")
annex_floor.rooms.find_or_create_by!(name: "Everest")
annex_floor.rooms.find_or_create_by!(name: "Huddle 2A")
annex_floor.rooms.find_or_create_by!(name: "Huddle 2B")

{
  "Summit Left" => [ summit, { model_identifier: "AppleTV14,1", os_version: "27.0", display_width: 3840, display_height: 2160, display_hdr: true, network: :ethernet } ],
  "Summit Right" => [ summit, { model_identifier: "AppleTV5,3", os_version: "26.6", display_width: 1920, display_height: 1080, display_hdr: false, network: :wifi } ],
  "Everest TV" => [ everest, { model_identifier: "AppleTV11,1", os_version: "26.6", display_width: 3840, display_height: 2160, display_hdr: true, network: :wifi } ]
}.each do |name, (room, info)|
  device = Device.find_or_create_by!(name: name) do |device|
    device.device_identifier = SecureRandom.uuid
    device.status = :paired
    device.room = room
    device.paired_at = 3.days.ago
  end
  device.update!(info.merge(app_version: "1.0 (1)", info_reported_at: 5.minutes.ago))
end

pending = Device.create!(device_identifier: SecureRandom.uuid, name: "New Apple TV")
pending.issue_pairing_code
pending.save!
puts "Pairing code for a new device (expires in 15 minutes): #{pending.pairing_code}"
