# frozen_string_literal: true

require 'shellwords'
require 'fileutils'

module PhotoShrinker
  class ImageHandler
    include ErrorHandler

    def initialize(image_path:, sub_directory:)
      @image_path = image_path
      @sub_directory = sub_directory
    end

    def call
      if File.exist?(target_file_path)
        log('SKIPPED! File already exists.')
        return
      end

      sub_path = options.target_directory + sub_directory
      FileUtils.mkdir_p(sub_path)
      optimized_file_name = sub_path + file_name

      begin
        # rubocop:disable Style/CommandLiteral
        # rubocop:disable Layout/LineLength
        result = %x[
          convert -interlace Plane -gaussian-blur 0.05 -quality 60%
          -adaptive-resize 60% #{escape(image_path)} #{escape(optimized_file_name)}
        ]
        # rubocop:enable Style/CommandLiteral
        # rubocop:enable Layout/LineLength
        if File.exist?(optimized_file_name) && result
          # puts("removing [#{file_name}]")
          # FileUtils.rm_f(image_path)
        else
          puts("Convert [#{file_name}] FAILED!")
        end
      rescue StandardError => e
        puts("Convert [#{file_name}] FAILED!")
        puts(e.message)
        # Master/iPhoto/Brasil/BRESIL/SAM_0367.JPG
      end

      nil
    end

    private

    def file_name
      File.basename(image_path.to_s)
    end

    def escape(expr)
      Shellwords.escape(expr.to_s)
    end

    def options
      PhotoShrinker.configuration.options
    end

    attr_reader :image_path, :sub_directory
  end
end
