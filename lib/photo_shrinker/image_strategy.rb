# frozen_string_literal: true

module PhotoShrinker
  class ImageStrategy
    prepend BaseStrategy

    # rubocop:disable Metrics/MethodLength
    def call
      cmds = [
        'mogrify',
        '-path',
        escape(File.dirname(target_path)),
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
        escape(media_path.to_s)
      ]
      system(cmds.join(' '))
    end
    # rubocop:enable Metrics/MethodLength

    def self.filters
      '{jpg,jpeg}'
    end
  end
end
