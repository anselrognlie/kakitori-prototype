# frozen_string_literal: true

class User < ApplicationRecord
  has_many :user_settings

  def log_activity
    self.last_activity = Time.now.utc
    success = false

    begin
      success = save
    rescue StandardError
      raise UserRepositoryError, 'error accessing user repository'
    end

    raise UserRepositoryError, 'error logging user activity' unless success
  end

  class << self
    def most_recent
      User.order(last_activity: :desc).limit(1)[0]
    end

    def make_default
      user = default_user
      return user unless user.nil?

      user = User.new(username: :default, default: true, last_activity: Time.now.utc)
      success = false

      begin
        success = user.save
      rescue StandardError
        raise UserRepositoryError, 'error accessing user repository'
      end

      raise UserRepositoryError, 'error creating default user' unless success

      user
    end

    def default_user
      User.find_by(default: true)
    end
  end
end
