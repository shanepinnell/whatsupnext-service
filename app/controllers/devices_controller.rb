class DevicesController < ApplicationController
  before_action :set_rooms, only: %i[ edit update ]

  # GET /devices
  def index
    @devices = Device.listed
  end

  # GET /devices/1
  def show
    @device = Device.find(params.expect(:id))
  end

  # GET /devices/1/edit
  def edit
    @device = Device.find(params.expect(:id))
  end

  # PATCH /devices/1
  def update
    @device = Device.find(params.expect(:id))
    if @device.update(params.expect(device: [ :room_id ]))
      redirect_to @device, notice: "Device updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_rooms
      @rooms = Room.includes(floor: { building: :site }).sort_by(&:path_label)
    end
end
