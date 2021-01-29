# frozen_string_literal: true

require 'shellwords'
require 'tty-command'
module PhotoShrinker
  module BaseStrategy
    def initialize(media_path:, target_path:)
      @media_path = media_path
      @target_path = target_path
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def call
      if File.exist?(target_path)
        log('SKIPPED! File already exists.')
        return
      end

      begin
        cmd = TTY::Command.new(printer: printer_mode)
        result = cmd.run(super)

        # Preserve File System Timestamps
        orignal_date_time = File.ctime(media_path.to_s)
        system(
          "touch -a -m -t #{orignal_date_time.strftime("%Y%m%d%H%M")} #{escape(target_path)}"
        )

        log("[#{format_size(File.size(media_path))}] => [#{format_size(File.size(target_path))}]")

        if File.exist?(target_path) && result.success?
          if options.delete
            log("removing [#{file_name}]")
            FileUtils.rm_f(media_path)
          end
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

    private

    attr_reader :media_path, :target_path

    def printer_mode
      return :null unless options.verbose

      :pretty
    end

    def file_name
      File.basename(media_path)
    end

    def escape(expr)
      Shellwords.escape(expr.to_s)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def format_size(size)
      conv = %w[b kb mb gb tb pb eb]
      scale = 1024

      ndx = 1
      return "#{size} #{conv[ndx - 1]}" if size < 2 * (scale**ndx)

      size = size.to_f
      [2, 3, 4, 5, 6, 7].each do |index|
        if size < 2 * (scale**index)
          return "#{format(
            "%<offset>.2f", offset: (size / (scale**(index - 1)))
          )} #{conv[index - 1]}"
        end
      end
      ndx = 7
      "#{format("%<offset>.2f", offset: (size / (scale**(ndx - 1))))} #{conv[ndx - 1]}"
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def options
      PhotoShrinker.configuration.options
    end
  end
end
