# frozen_string_literal: true

require 'active_support/duration'
module PhotoShrinker
  module Measuring
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def call
      start  = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      before = GC.stat(:total_allocated_objects)

      result = super

      after    = GC.stat(:total_allocated_objects)
      duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start)

      sub_info = if duration < 1
                   "#{(duration * 1000).round(1)}ms"
                 else
                   ActiveSupport::Duration.build(duration).parts.map do |key, value|
                     [value.to_i, key].join(' ')
                   end.join(' ')
                 end

      info = "Completed in #{sub_info} | Allocations: #{after - before}"

      puts("\e[1m\e[32m[METRICS]\e[0m  \e[32m#{info}\e[0m")

      result
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
