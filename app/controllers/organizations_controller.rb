class OrganizationsController < ApplicationController
  def show
    @organization = Organization.first || Organization.new
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      redirect_to root_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  def edit
    @organization = Organization.first
  end

  def update
    @organization = Organization.first

    if @organization.update(organization_update_params)
      redirect_to root_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name)
  end

  def organization_update_params
    params.require(:organization).permit(:name, :support_information)
  end
end
