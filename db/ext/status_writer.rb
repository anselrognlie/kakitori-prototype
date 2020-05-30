# frozen_string_literal: true

module KVG
  class LinePrinter
    def print(str)
      line = "\r#{str}"
      spaces = last_len - line.length
      line = "#{line}#{' ' * spaces}" if spaces.positive?
      @last_str = str.to_s
      global_print line
    end

    def clear
      line = "\r#{' ' * last_len}"
      @last_str = nil
      global_print line
    end

    def done
      puts
    end

    private

    def last_len
      @last_str&.length || 0
    end

    def global_print(str)
      Object.instance_method(:print).bind(self).call(str)
    end
  end

  class StatusWriter
    def initialize(printer = nil)
      @printer = printer || LinePrinter.new
      start
    end

    def start(count: 0, template: '')
      @step = 0
      @step_count = count
      @template = template
    end

    def next_step(msg)
      @step += 1
      line = format(
        @template, step: msg, num: @step, total: @step_count,
                   percent: step_percent
      )
      @printer.print(line)
    end

    def done
      @printer.done
      start
    end

    private

    def step_percent
      @step_count.zero? ? 0 : (@step * 100.0 / @step_count).round
    end
  end
end
