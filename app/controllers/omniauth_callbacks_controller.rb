class OmniauthCallbacksController < ApplicationController
  allow_unauthenticated_access only: %i[ create ]

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_by!(email_address: auth.info.email)
    start_new_session_for(user)
    redirect_to after_authentication_url
  end
end
