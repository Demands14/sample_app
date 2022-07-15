class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t ".warning"
    redirect_to root_path
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      redirect_to @user
      flash[:success] = t ".success"
    else
      flash[:danger] = t ".danger"
      render :new
    end
  end

  private
  def user_params
    params.require(:user).permit User::USER_ATTRS
  end
end
