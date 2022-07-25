class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :find_user, except: %i(new create index)
  before_action :admin_user, only: %i(destroy)
  before_action :correct_user, only: %i(edit update)

  def new
    @user = User.new
  end

  def show; end

  def index
    @pagy, @users = pagy User.name_asc
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".check_email"
      redirect_to login_url
    else
      flash[:danger] = t ".danger"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".success"
      redirect_to @user
    else
      flash[:danger] = t ".danger"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".danger")
    end
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit User::USER_ATTRS
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t ".warning"
    redirect_to root_path
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash.now[:danger] = ".danger"
    redirect_to login_url
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = ".danger"
    redirect_to root_path
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
