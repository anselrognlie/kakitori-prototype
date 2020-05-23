# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, except: %i[update]

  def show; end

  def edit
    user = User.find_by_id(id_params)
    if user.nil?
      flash.now[:error] = 'Unable to find user.'
      render_pick(User.new)
      return
    end

    @user = user
  end

  def pick
    render_pick(User.new)
  end

  def create
    user = User.new(model_params)

    if user.save
      flash.now[:success] = "Created user #{user.username}."
      user = User.new
    else
      flash.now[:warning] = 'User creation failed.'
    end

    render_pick(user)
  end

  def select
    user = User.find_by_id(id_params)
    if user.nil?
      flash.now[:error] = 'Unable to find selected user.'
    else
      self.current_user = user
    end

    render_pick(User.new)
  end

  def update
    @user = User.find_by_id(id_params)
    if @user.nil?
      flash[:error] = 'Unable to find selected user.'
      redirect_to root_path
      return
    end

    if cancel?
      render :show
      return
    end

    apply_changes(@user, model_params)

    if @user.save
      self.current_user = @user
      flash[:success] = 'User updated.'
      # redirect_to @user
      render :show
    else
      render :edit
    end
  end

  def destroy
    user = User.find_by_id(id_params)
    if user.nil?
      flash.now[:error] = 'Unable to find user for deletion.'
    elsif user.destroy
      flash.now[:success] = "Deleted user #{user.username}."
    else
      flash.now[:error] = "Failed to delete user #{user.username}."
    end

    render_pick(User.new)
  end

  private

  def render_pick(current_user)
    @user = current_user
    @users = User.all.order(username: :asc)
    render :pick
  end

  def apply_changes(user, params)
    username = params[:username]&.strip
    user.username = username if username&.length&.positive?
    user.refresh_activity
  end

  def set_user
    @user = @current_user
  end

  def id_params
    params.require(:id)
  end

  def model_params
    params.require(:user).permit(:username)
  end

  def cancel?
    params[:commit].nil?
  end
end
