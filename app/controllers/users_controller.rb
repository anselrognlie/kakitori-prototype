# frozen_string_literal: true

class UsersController < ApplicationController
  # skip_before_action :update_current_user, only: %i[select_user]

  def select_user
    # user = most_recent_user
    # user = make_default_user if user.nil?
    # self.current_user = user
  end

  private

end
