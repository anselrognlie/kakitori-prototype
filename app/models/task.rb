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

  def complete_single
    name = task_type
    return false unless destroy

    Lock.release(name: name)
  end
end
