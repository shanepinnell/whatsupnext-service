class FloorsController < ApplicationController
  before_action :set_site
  before_action :set_building
  before_action :set_floor, only: %i[ show edit update destroy ]

  # GET /sites/1/buildings/1/floors
  def index
    @floors = @building.floors
  end

  # GET /sites/1/buildings/1/floors/1
  def show
  end

  # GET /sites/1/buildings/1/floors/new
  def new
    @floor = @building.floors.build
  end

  # GET /sites/1/buildings/1/floors/1/edit
  def edit
  end

  # POST /sites/1/buildings/1/floors
  def create
    @floor = @building.floors.build(floor_params)

    if @floor.save
      redirect_to [ @site, @building, @floor ], notice: "Floor was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /sites/1/buildings/1/floors/1
  def update
    if @floor.update(floor_params)
      redirect_to [ @site, @building, @floor ], notice: "Floor was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /sites/1/buildings/1/floors/1
  def destroy
    if @floor.destroy
      redirect_to site_building_floors_path(@site, @building), notice: "Floor was successfully destroyed.", status: :see_other
    else
      redirect_to site_building_floors_path(@site, @building), alert: @floor.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_site
      @site = Site.find(params.expect(:site_id))
    end

    def set_building
      @building = @site.buildings.find(params.expect(:building_id))
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_floor
      @floor = @building.floors.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def floor_params
      params.expect(floor: [ :name ])
    end
end
