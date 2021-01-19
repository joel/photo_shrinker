# frozen_string_literal: true

module PhotoShrinker
  module ErrorHandler
    def safe_exe(msg: nil)
      r = nil
      begin
        r = yield
      rescue StandardError => e
        puts("[#{msg}] Execution Error")
        puts(e.message)
      end
      r
    end
  end
end
