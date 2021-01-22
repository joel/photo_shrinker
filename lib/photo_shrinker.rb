# frozen_string_literal: true

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem

core_ext = "#{__dir__}/core_ext"
loader.ignore(core_ext)

loader.setup

def log(msg)
  PhotoShrinker.configuration.logger.info(msg)
end

require_relative 'core_ext/string/filters'

require 'json'
require 'thwait'
require 'tty-progressbar'
require 'pathname'

Thread.abort_on_exception = true
Thread.ignore_deadlock = false

module PhotoShrinker
  extend Configure
  class Main
    prepend Measuring

    def initialize
      @queue = Queue.new # SizedQueue.new(1)
      @progress_bar = TTY::ProgressBar.new('shrinking [:bar]', total: collection.size)
    end

    def call
      initial_size = directory_size
      producer = queueing

      consumers = []
      options.parallel.times.each { |consumer_number| consumers << get_consumer(consumer_number) }

      # rubocop:disable Lint/RescueException
      # rubocop:disable Lint/SuppressedException
      begin
        ThreadsWait.all_waits(*([producer] + consumers)) do |thread|
          log("Thread #{thread} has terminated.")
        end
      rescue Exception # queue.pop: No live threads left. Deadlock? (fatal)
      end
      # rubocop:enable Lint/RescueException
      # rubocop:enable Lint/SuppressedException

      final_size = directory_size(refresh: true, directory: options.target_directory)

      reduction = 100 - final_size * 100 / initial_size
      puts("\e[1m\e[32m[REDUCING BY]\e[0m  \e[32m-#{reduction}%\e[0m")
    end

    private

    def directory_size(refresh: false, directory: options.source_directory)
      @collection = nil if refresh
      collection(directory: directory).map { |media_path| File.size(media_path) }.sum
    end

    def collection(directory: options.source_directory)
      @collection ||= begin
        filters = Object.const_get("PhotoShrinker::#{options.media.to_s.capitalize}Strategy").filters
        Dir.glob("#{directory}/**/*.#{filters}").map do |entry|
          Pathname(entry)
        end
      end
    end

    def options
      PhotoShrinker.configuration.options
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def queueing
      Thread.new do
        collection.each do |media_path|
          log("Reading... [#{File.basename(media_path).downcase}]")
          sub_directory = Pathname(
            File.dirname(
              (p2a(media_path) - p2a(options.source_directory))
                .join('/')
            )
          )
          queue << { media_path: media_path, sub_directory: sub_directory }.to_json
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def p2a(path)
      path.to_s.split('/')
    end

    def get_consumer(consumer_number)
      Thread.new do
        while (info = queue.pop)
          info = JSON.parse(info).transform_keys(&:to_sym)
          log("[#{consumer_number}] consumed #{info[:media_path]}")
          MediaHandler.new(**info).call
          progress_bar.advance
        end
      end
    end

    attr_reader :queue, :progress_bar
  end

  class Error < StandardError; end
end
