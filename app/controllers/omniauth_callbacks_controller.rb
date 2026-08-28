class OmniauthCallbacksController < ApplicationController
  allow_unauthenticated_access only: %i[ create failure ]

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_by!(email_address: auth.info.email)
    start_new_session_for(user)
    redirect_to after_authentication_url
  end

  def failure
    redirect_to new_session_path, alert: "Sign-in failed: #{params[:message].to_s.humanize}"
  end
end
