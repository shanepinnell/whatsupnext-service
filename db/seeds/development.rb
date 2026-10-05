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

{ "Summit Left" => summit, "Summit Right" => summit, "Everest TV" => everest }.each do |name, room|
  Device.find_or_create_by!(name: name) do |device|
    device.device_identifier = SecureRandom.uuid
    device.status = :paired
    device.room = room
    device.paired_at = 3.days.ago
  end
end

pending = Device.create!(device_identifier: SecureRandom.uuid, name: "New Apple TV")
pending.issue_pairing_code
pending.save!
puts "Pairing code for a new device (expires in 15 minutes): #{pending.pairing_code}"
