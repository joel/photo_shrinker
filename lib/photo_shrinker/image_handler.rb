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

    def target_path
      sub_path = options.target_directory + sub_directory
      FileUtils.mkdir_p(sub_path)
      sub_path + file_name
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def call
      optimized_file_name = target_path

      if File.exist?(optimized_file_name)
        log('SKIPPED! File already exists.')
        return
      end

      begin
        cmds = [
          'mogrify',
          '-path',
          escape(File.dirname(optimized_file_name)),
          '-filter',
          'Triangle',
          '-define',
          'filter:support=2',
          '-unsharp 0.25x0.25+8+0.065',
          '-dither None',
          '-posterize 136',
          '-quality 82',
          '-define jpeg:fancy-upsampling=off',
          '-define png:compression-filter=5',
          '-define png:compression-level=9',
          '-define png:compression-strategy=1',
          '-define png:exclude-chunk=all',
          '-interlace none',
          '-colorspace sRGB',
          '-strip',
          escape(image_path.to_s)
        ]
        result = system(cmds.join(' '))

        log("[#{format_size(File.size(image_path))}] => [#{format_size(File.size(optimized_file_name))}]")

        if File.exist?(optimized_file_name) && result
          # TODO: Implement removing of original file --delete
          # puts("removing [#{file_name}]")
          # FileUtils.rm_f(image_path)
        else
          puts("Convert [#{file_name}] FAILED!")
        end
      rescue StandardError => e
        puts("Convert [#{file_name}] FAILED!")
        puts(e.message)
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

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

    def format_size(size) # rubocop:disable Metrics/AbcSize
      conv = %w[b kb mb gb tb pb eb]
      scale = 1024

      ndx = 1
      return "#{size} #{conv[ndx - 1]}" if size < 2 * (scale**ndx)

      size = size.to_f
      [2, 3, 4, 5, 6, 7].each do |index|
        return "#{format("%.2f", (size / (scale**(index - 1))))} #{conv[index - 1]}" if size < 2 * (scale**index)
      end
      ndx = 7
      "#{format("%.2f", (size / (scale**(ndx - 1))))} #{conv[ndx - 1]}"
    end

    attr_reader :image_path, :sub_directory
  end
end
