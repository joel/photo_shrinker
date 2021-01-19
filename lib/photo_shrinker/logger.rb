# frozen_string_literal: true

module PhotoShrinker
  class Logger
    def info(msg)
      return unless PhotoShrinker.configuration.verbose

      puts(msg)
    end
  end
end
