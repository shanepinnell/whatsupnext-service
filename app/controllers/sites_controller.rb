class SitesController < ApplicationController
  before_action :set_site, only: %i[ show edit update destroy ]

  # GET /sites
  def index
    @sites = Site.all
  end

  # GET /sites/1
  def show
  end

  # GET /sites/new
  def new
    @site = Organization.first.sites.build
  end

  # GET /sites/1/edit
  def edit
  end

  # POST /sites
  def create
    @site = Organization.first.sites.build(site_params)

    if @site.save
      redirect_to @site, notice: "Site was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /sites/1
  def update
    if @site.update(site_params)
      redirect_to @site, notice: "Site was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /sites/1
  def destroy
    if @site.destroy
      redirect_to sites_path, notice: "Site was successfully destroyed.", status: :see_other
    else
      redirect_to sites_path, alert: @site.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def site_params
      params.expect(site: [ :name ])
    end
end
