# frozen_string_literal: true

module PhotoShrinker
  class Configuration
    attr_accessor :verbose, :logger, :options

    def initialize
      self.verbose = false
      self.logger = Logger.new
      self.options = {}
    end
  end
end
