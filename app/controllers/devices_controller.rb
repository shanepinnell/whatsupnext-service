class DevicesController < ApplicationController
  # GET /devices
  def index
    @devices = Device.order(:created_at)
  end

  # GET /devices/1
  def show
    @device = Device.find(params.expect(:id))
  end
end
