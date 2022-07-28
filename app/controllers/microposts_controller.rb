class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :find_micropost, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach params[:micropost][:image]
    if @micropost.save
      flash[:success] = t ".success"
      redirect_to root_url
    else
      excep_create_handle
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t ".success"
    else
      flash[:danger] = t ".danger"
    end
    redirect_to request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def excep_create_handle
    flash.now[:danger] = t ".danger"
    @pagy, @feed_items = pagy current_user.feed.newest
    render "static_pages/home"
  end

  def find_micropost
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t ".danger"
    redirect_to root_url
  end
end
