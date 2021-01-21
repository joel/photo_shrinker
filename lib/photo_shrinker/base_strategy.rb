# frozen_string_literal: true

require 'shellwords'

module PhotoShrinker
  module BaseStrategy
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def call
      if File.exist?(target_path)
        log('SKIPPED! File already exists.')
        return
      end

      begin
        result = super

        log("[#{format_size(File.size(media_path))}] => [#{format_size(File.size(target_path))}]")

        if File.exist?(target_path) && result
          # TODO: Implement removing of original file --delete
          # log("removing [#{file_name}]")
          # FileUtils.rm_f(media_path)
        else
          log("Convert [#{file_name}] FAILED!")
        end
      rescue StandardError => e
        log("Convert [#{file_name}] FAILED!")
        log(e.message)
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def escape(expr)
      Shellwords.escape(expr.to_s)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Style/FormatStringToken
    def format_size(size)
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
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Style/FormatStringToken
  end
end
