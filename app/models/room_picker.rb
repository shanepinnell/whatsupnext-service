class RoomPicker
  attr_reader :sites, :site, :buildings, :building, :floors, :floor, :rooms, :room

  def initialize(room:, site_id: nil, building_id: nil, floor_id: nil)
    current = room if [ site_id, building_id, floor_id ].all?(&:nil?)

    @sites = Site.order(:name)
    @site = pick(@sites, site_id, current&.floor&.building&.site)
    @buildings = @site ? @site.buildings.order(:name) : Building.none
    @building = pick(@buildings, building_id, current&.floor&.building)
    @floors = @building ? @building.floors.order(:position) : Floor.none
    @floor = pick(@floors, floor_id, current&.floor)
    @rooms = @floor ? @floor.rooms.order(:name) : Room.none
    @room = pick(@rooms, nil, current)
  end

  private
    def pick(options, id, default)
      chosen = options.find_by(id: id) if id.present?
      chosen || (default if default && options.include?(default)) || (options.first if options.one?)
    end
end
