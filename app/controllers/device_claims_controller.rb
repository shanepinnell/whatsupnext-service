class DeviceClaimsController < ApplicationController
  before_action :set_site, :set_building, :set_floor, :set_room

  # GET /sites/1/buildings/1/floors/1/rooms/1/device_claim/new
  def new
  end

  # POST /sites/1/buildings/1/floors/1/rooms/1/device_claim
  def create
    Device.claim!(code: params[:code].to_s.strip, room: @room)
    redirect_to [ @site, @building, @floor, @room ], notice: "Device paired."
  end

  private
    def set_site
      @site = Site.find(params.expect(:site_id))
    end

    def set_building
      @building = @site.buildings.find(params.expect(:building_id))
    end

    def set_floor
      @floor = @building.floors.find(params.expect(:floor_id))
    end

    def set_room
      @room = @floor.rooms.find(params.expect(:room_id))
    end
end
