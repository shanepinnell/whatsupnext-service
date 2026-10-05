class DevicesController < ApplicationController
  # GET /devices/1
  def show
    @device = Device.find(params.expect(:id))
  end
end
