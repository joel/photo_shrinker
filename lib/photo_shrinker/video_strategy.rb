# frozen_string_literal: true

module PhotoShrinker
  class VideoStrategy
    prepend BaseStrategy

    def call
      cmd = <<-CMD.squish
        ffmpeg -n -loglevel error
        -i #{escape(media_path)} -vcodec libx264
        -crf 28 -preset faster
        -tune film #{escape(target_path)}
      CMD

      system(cmd)
    end

    def self.filters
      '{avi,flv,m4v,mov,wmv,mp4,MP4,TS,mkv}'
    end
  end
end
