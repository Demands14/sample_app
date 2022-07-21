class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase

    if user&.authenticate params[:session][:password]
      log_in user
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_to user
    else
      excep_handle
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
  def excep_handle
    flash.now[:danger] = t ".danger"
    render :new
  end
end
