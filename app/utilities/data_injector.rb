# frozen_string_literal: true

class DataInjector
  def inject_as_ivars(data, target)
    data.each do |k, v|
      target.instance_variable_set(k, v)
    end
  end
end
