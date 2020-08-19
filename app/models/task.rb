# frozen_string_literal: true

class Task < ApplicationRecord
  def self.create_single(task_type:)
    Lock.transaction do
      return nil unless Lock.try_lock(name: task_type)

      task = Task.new(task_type: task_type)
      return nil unless task.save

      task
    end
  end

  def self.running?(task_type:)
    task = Task.where(task_type: task_type).first
    !task.nil?
  end

  def self.complete_single(task_type:)
    task = Task.where(task_type: task_type).first
    task&.complete_single
  end

  def complete_single
    name = task_type
    return false unless destroy

    Lock.release(name: name)
  end
end
