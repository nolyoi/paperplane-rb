# frozen_string_literal: true

require 'http'
require 'paperplane/error'
require 'paperplane/version'

module Paperplane
  class << self
    BASE_URL = 'https://api.paperplane.app/v1'.freeze
    ENDPOINTS = {
      create_job: '/jobs',
      show_job: '/jobs/%{id}',
      download_pdf: 'https://download.paperplane.app/'
    }.freeze
    PAGE_SIZES = %w[A4 Letter Legal Tabloid].freeze

    attr_accessor :api_key

    def create_job(url, page_size = 'A4')
      validate_page_size!(page_size)
      perform_request(:post, :create_job, url, page_size:)
    end

    def show_job(id)
      perform_request(:get, :show_job, id)
    end

    def download_pdf(url, page_size = 'A4')
      validate_page_size!(page_size)
      perform_request(:post, :download_pdf, url, page_size:)
    end

    private

    def http_client
      @http_client ||= HTTP.basic_auth(user: self.api_key, pass: '')
    end

    def perform_request(method, endpoint_name, *args)
      url = build_url(endpoint_name, args[0])
      response = http_client.request(method, url, json: args[1])
      validate_response!(response)
    end

    def build_url(endpoint_name, id)
      endpoint = ENDPOINTS[endpoint_name]
      endpoint.include?('://') ? endpoint : "#{BASE_URL}#{format(endpoint, id:)}"
    end

    def validate_response!(response)
      raise Paperplane::Error, response.parse['message'] if response.status >= 400
      response.parse
    end

    def validate_page_size!(page_size)
      raise ArgumentError, "Invalid page size '#{page_size}'" unless PAGE_SIZES.include?(page_size)
    end
  end
end
