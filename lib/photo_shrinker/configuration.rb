# frozen_string_literal: true

module PhotoShrinker
  class Configuration
    attr_accessor :logger, :options

    def initialize
      self.options = {}
    end
  end
end
