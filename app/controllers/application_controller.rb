# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :update_current_user, :prepare_alert

  def update_current_user
    user = current_user
    user = make_default_user if user.nil?
    user&.log_activity
  rescue UserError => e
    flash[:error] = e.message
    redirect_to error_path
  end

  def prepare_alert
    @alert = AlertTypes.new(flash)
  end

  def current_user
    # if we already looked up the current user, use that
    return @current_user unless @current_user.nil?

    # rehydrate the current user
    id = session[:user_id]
    unless id.nil?
      @current_user = User.find_by_id(id)
      return @current_user
    end

    # get the most recent user
    most_recent_user
  end

  def current_user=(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def most_recent_user
    user = User.most_recent
    self.current_user = user unless user.nil?
    user
  end

  private

  def make_default_user
    user = User.make_default
    self.current_user = user unless user.nil?
    user
  end
end
