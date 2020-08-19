# frozen_string_literal: true

class WkUpdateScheduler
  def schedule(api_key:)
    # take task lock
    lock = WkUpdateTask.lock
    return unless lock

    # schedule job
    WkLevelsImportJob.perform_later(api_key)
  end
end
