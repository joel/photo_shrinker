# frozen_string_literal: true

module PhotoShrinker
  class NullLogger
    def info(_)
      nil
    end

    def level=(level) end
  end
end
