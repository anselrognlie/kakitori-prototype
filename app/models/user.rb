# frozen_string_literal: true

class User < ApplicationRecord
  has_many :user_settings

  validates :username, presence: true
  validates :last_activity, presence: true

  def initialize(args = nil)
    super(args)
    # self.last_activity = Time.new(0).utc
    refresh_activity
  end

  def refresh_activity
    self.last_activity = Time.now.utc
  end

  def log_activity
    refresh_activity
    success = false

    begin
      success = save
    rescue StandardError
      raise UserRepositoryError, 'error accessing user repository'
    end

    raise UserRepositoryError, 'error logging user activity' unless success
  end

  class << self
    DEFAULT_USERNAME = 'Default User'

    def most_recent
      order(last_activity: :desc).limit(1).first
    end

    def make_default
      user = default
      return user unless user.nil?

      user = User.new(username: DEFAULT_USERNAME)
      user.refresh_activity
      success = false

      begin
        success = user.save
      rescue StandardError
        raise UserRepositoryError, 'error accessing user repository'
      end

      raise UserRepositoryError, 'error creating default user' unless success

      user
    end

    def default
      most_recent
    end
  end
end
