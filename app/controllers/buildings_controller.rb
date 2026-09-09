class BuildingsController < ApplicationController
  before_action :set_site
  before_action :set_building, only: %i[ show edit update destroy ]

  # GET /sites/1/buildings
  def index
    @buildings = @site.buildings
  end

  # GET /sites/1/buildings/1
  def show
  end

  # GET /sites/1/buildings/new
  def new
    @building = @site.buildings.build
  end

  # GET /sites/1/buildings/1/edit
  def edit
  end

  # POST /sites/1/buildings
  def create
    @building = @site.buildings.build(building_params)

    if @building.save
      redirect_to [ @site, @building ], notice: "Building was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /sites/1/buildings/1
  def update
    if @building.update(building_params)
      redirect_to [ @site, @building ], notice: "Building was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /sites/1/buildings/1
  def destroy
    if @building.destroy
      redirect_to site_buildings_path(@site), notice: "Building was successfully destroyed.", status: :see_other
    else
      redirect_to site_buildings_path(@site), alert: @building.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_site
      @site = Site.find(params.expect(:site_id))
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = @site.buildings.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def building_params
      params.expect(building: [ :name, :timezone ])
    end
end
