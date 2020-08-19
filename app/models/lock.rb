# frozen_string_literal: true

class Lock < ApplicationRecord
  def self.try_lock(name:)
    Lock.create(name: name)
    true
  rescue ActiveRecord::RecordNotUnique
    false
  end

  def self.release(name:)
    lock = Lock.where(name: name).first
    return false unless lock

    lock.destroy
  end
end
