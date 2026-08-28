class OrganizationsController < ApplicationController
  def show
    @organization = Organization.first
  end
end
