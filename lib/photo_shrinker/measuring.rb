# frozen_string_literal: true

module PhotoShrinker
  module Measuring
    def call
      start  = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      before = GC.stat(:total_allocated_objects)

      result = super

      after    = GC.stat(:total_allocated_objects)
      duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start)

      info = "Completed in #{(duration * 1000).round(1)}ms | Allocations: #{after - before}"

      puts("\e[1m\e[32m[METRICS]\e[0m  \e[32m#{info}\e[0m")

      result
    end
  end
end
