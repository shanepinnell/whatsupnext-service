class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new ]
  rate_limit to: 10, within: 3.minutes, only: :destroy, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
