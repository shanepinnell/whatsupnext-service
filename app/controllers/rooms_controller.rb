class RoomsController < ApplicationController
  before_action :set_site
  before_action :set_building
  before_action :set_floor
  before_action :set_room, only: %i[ show edit update destroy ]

  # GET /sites/1/buildings/1/floors/1/rooms
  def index
    @rooms = @floor.rooms
  end

  # GET /sites/1/buildings/1/floors/1/rooms/1
  def show
  end

  # GET /sites/1/buildings/1/floors/1/rooms/new
  def new
    @room = @floor.rooms.build
  end

  # GET /sites/1/buildings/1/floors/1/rooms/1/edit
  def edit
  end

  # POST /sites/1/buildings/1/floors/1/rooms
  def create
    @room = @floor.rooms.build(room_params)

    if @room.save
      redirect_to [ @site, @building, @floor, @room ], notice: "Room was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /sites/1/buildings/1/floors/1/rooms/1
  def update
    if @room.update(room_params)
      redirect_to [ @site, @building, @floor, @room ], notice: "Room was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /sites/1/buildings/1/floors/1/rooms/1
  def destroy
    if @room.destroy
      redirect_to site_building_floor_rooms_path(@site, @building, @floor), notice: "Room was successfully destroyed.", status: :see_other
    else
      redirect_to site_building_floor_rooms_path(@site, @building, @floor), alert: @room.errors.full_messages.to_sentence, status: :see_other
    end
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

    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = @floor.rooms.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def room_params
      params.expect(room: [ :name, :background_image ])
    end
end
