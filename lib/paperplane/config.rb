# frozen_string_literal: true
require 'logger'

class Config
  attr_accessor :api_key, :logger

  def initialize
    @api_key = ''
    @logger = Logger.new(STDOUT)
  end
end