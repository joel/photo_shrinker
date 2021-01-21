# frozen_string_literal: true

require 'fileutils'

module PhotoShrinker
  class MediaHandler
    include ErrorHandler

    def initialize(media_path:, sub_directory:)
      @media_path = media_path
      @sub_directory = sub_directory
    end

    def call
      MediaStrategy.new(media_path: media_path, target_path: target_path).call
    end

    private

    def target_path
      sub_path = options.target_directory + sub_directory
      FileUtils.mkdir_p(sub_path)
      sub_path + file_name
    end

    def file_name
      File.basename(media_path.to_s)
    end

    def options
      PhotoShrinker.configuration.options
    end

    attr_reader :media_path, :sub_directory
  end
end
