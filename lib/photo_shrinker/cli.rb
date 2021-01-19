# frozen_string_literal: true

require 'optparse'
require 'pathname'

module PhotoShrinker
  class OptparseExample
    class ScriptOptions
      attr_accessor :verbose, :source_directory, :target_directory, :parallel

      def initialize
        self.verbose = false
        self.source_directory = './fixtures/unshrinked'
        self.target_directory = './fixtures/shrinked'
        self.parallel = 8
      end

      def define_options(parser) # rubocop:disable Metrics/MethodLength
        parser.banner = 'Usage: bin/sort -s /Volume/Ext/Source -t /Volume/Ext/Destination --verbose'
        parser.separator ''
        parser.separator 'Specific options:'

        # add additional options
        source_directory_option(parser)
        target_directory_option(parser)
        parallel_option(parser)

        boolean_verbose_option(parser)

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

      def boolean_verbose_option(parser)
        # Boolean switch.
        parser.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
          self.verbose = v
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
      PhotoShrinker.configure do |conf|
        conf.verbose = options.verbose
        conf.options = options
      end
      PhotoShrinker::Main.new.call
    end

    def help(opts)
      puts(opts)
    end

    attr_reader :options
  end
end