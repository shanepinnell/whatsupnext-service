class DevicesController < ApplicationController
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
    @room_picker = RoomPicker.new(room: @device.room, site_id: params[:site_id], building_id: params[:building_id], floor_id: params[:floor_id])
  end

  # PATCH /devices/1
  def update
    @device = Device.find(params.expect(:id))
    if @device.update(params.expect(device: [ :room_id ]))
      redirect_to @device, notice: "Device updated."
    else
      @room_picker = RoomPicker.new(room: Room.find_by(id: @device.room_id_in_database))
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /devices/1
  def destroy
    Device.find(params.expect(:id)).destroy!
    redirect_to devices_path, notice: "Device deleted.", status: :see_other
  end
end
