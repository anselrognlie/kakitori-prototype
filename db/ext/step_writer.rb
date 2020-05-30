# frozen_string_literal: true

module KTL
  class StepWriter
    class << self
      def log(msg, long: false, done_msg: nil, error_msg: nil, &block)
        init(msg, long, done_msg, error_msg, block)
        print @msg
        wait_for_task
        process_block
      end

      def done
        join
        puts @done_msg ? " #{@done_msg}" : ' done.' if @pending
        @pending = false
      end

      def error
        join
        puts @error_msg ? " #{@error_msg}" : ' error!' if @pending
        @pending = false
      end

      private

      TWIRL = %w[- \\ | /].freeze

      def init(msg, long, done_msg, error_msg, block)
        @msg = msg
        @pending = true
        @long = long
        @done = false
        @twirl = 0
        @done_msg = done_msg
        @error_msg = error_msg
        @block = block
      end

      def wait_for_task
        return unless @long

        print " #{twirl}"
        @thread = Thread.fork do
          twiddle
          until @done
            print "\r#{@msg} #{twirl}"
            sleep 1.0 / 8.0
          end
          print "\r#{@msg}"
        end
      end

      def twiddle
        sleep 1.0 / 4.0
      end

      def twirl
        str = TWIRL[@twirl]
        @twirl = (@twirl + 1) % TWIRL.count
        str
      end

      def join
        @done = true
        @thread&.join
      end

      def process_block
        return unless @block

        if @block.call
          done
        else
          error
        end
      end
    end
  end
end
