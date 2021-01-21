# frozen_string_literal: true

require 'forwardable'

module PhotoShrinker
  class MediaStrategy
    extend Forwardable

    # delegate :call, to: :strategy
    def_delegators :strategy, :call

    def initialize(media_path:, target_path:)
      @media_path = media_path
      @target_path = target_path
    end

    private

    attr_reader :media_path, :target_path

    def strategy
      @strategy ||= strategy_selector.new(media_path: media_path, target_path: target_path)
    end

    class MediaStrategyError < StandardError; end

    def strategy_selector
      case options.media.to_sym
      when :image then ImageStrategy
      when :video then VideoStrategy
      else
        raise MediaStrategyError, "Unknown media strategy [#{options.media}]"
      end
    end

    def options
      PhotoShrinker.configuration.options
    end
  end
end
