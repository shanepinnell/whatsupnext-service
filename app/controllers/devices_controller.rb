class DevicesController < ApplicationController
  # GET /devices
  def index
    @devices = Device.listed
  end

  # GET /devices/1
  def show
    @device = Device.find(params.expect(:id))
  end
end
