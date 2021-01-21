# frozen_string_literal: true

require 'optparse'
require 'pathname'
require 'tty-logger'
module PhotoShrinker
  class OptparseExample
    class ScriptOptions
      attr_accessor :verbose, :source_directory, :target_directory, :parallel, :media, :delete

      def initialize
        self.verbose = false
        self.source_directory = './fixtures/unshrinked'
        self.target_directory = './fixtures/shrinked'
        self.parallel = 8
        self.media = :image
        self.delete = false
      end

      def define_options(parser) # rubocop:disable Metrics/MethodLength
        parser.banner = 'Usage: bin/shrink -s /Volume/Ext/Source -t /Volume/Ext/Destination --verbose'
        parser.separator ''
        parser.separator 'Specific options:'

        # add additional options
        source_directory_option(parser)
        target_directory_option(parser)
        parallel_option(parser)
        media_option(parser)

        boolean_verbose_option(parser)
        boolean_delete_option(parser)

        parser.separator ''
        parser.separator 'Common options:'

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        parser.on_tail('-h', '--help', 'Show this message') do
          puts parser
          exit
        end
        # Another typical switch to print the version.
        parser.on_tail('--version', 'Show version') do
          puts PhotoShrinker::VERSION
          exit
        end

        parser
      end

      def parallel_option(parser)
        parser.on('-n PARALLEL', '--parallel PARALLEL', '[OPTIONAL] How many threads',
                  Integer) do |parallel|
          self.parallel = parallel
        end
      end

      def source_directory_option(parser)
        parser.on('-s SOURCE_DIRECTORY', '--source_directory SOURCE_DIRECTORY', '[OPTIONAL] Where the pictures are',
                  String) do |source_directory|
          self.source_directory = Pathname(source_directory)
        end
      end

      def target_directory_option(parser)
        parser.on('-t TARGET_DIRECTORY', '--target_directory TARGET_DIRECTORY',
                  '[OPTIONAL] Where the pictures will go', String) do |target_directory|
          self.target_directory = Pathname(target_directory)
        end
      end

      def media_option(parser)
        parser.on('--media [MEDIA]', %i[image video],
                  'Select the media type (image, video)') do |media|
          self.media = media
        end
      end

      def boolean_verbose_option(parser)
        parser.on('-v', '--[no-]verbose', 'Run verbosely') do |verbose|
          self.verbose = verbose
        end
      end

      def boolean_delete_option(parser)
        parser.on('-d', '--[no-]delete', '[WARNING] Delete the original files after the compression!') do |delete|
          self.delete = delete
        end
      end
    end

    #
    # Return a structure describing the options.
    #
    def parse(args)
      # The options specified on the command line will be collected in
      # *options*.
      @options = ScriptOptions.new
      @option_parser = OptionParser.new do |parser|
        @options.define_options(parser)
        parser.parse!(args)
      end
      @options
    end

    attr_reader :parser, :options, :option_parser
  end

  class Cli
    def initialize
      example = OptparseExample.new
      @options = example.parse(ARGV)

      return if options.source_directory && options.target_directory

      help(example.option_parser)
      exit(1)
    rescue OptionParser::InvalidArgument => e
      p e.message
      exit(1)
    end

    def call
      logger = NullLogger.new
      logger = TTY::Logger.new if options.verbose

      PhotoShrinker.configure do |conf|
        conf.options = options
        conf.logger = logger
      end

      PhotoShrinker.configuration.logger do |config|
        config.level = :info
      end

      PhotoShrinker::Main.new.call
    end

    def help(opts)
      puts(opts)
    end

    attr_reader :options
  end
end
