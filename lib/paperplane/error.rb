# frozen_string_literal: true

module Paperplane
  class Error < StandardError
    def initialize(message)
      Paperplane.config.logger.error(message)
      super(message)
    end
  end
end
