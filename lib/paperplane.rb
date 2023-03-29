# frozen_string_literal: true

require 'http'
require 'paperplane/error'
require 'paperplane/version'

module Paperplane
  ENDPOINTS = {
    create_job: 'https://api.paperplane.app/v1/jobs',
    show_job: 'https://api.paperplane.app/v1/jobs/%{id}',
    download_pdf: 'https://download.paperplane.app/'
  }.freeze
  PAGE_SIZES = %w[Letter Legal A3 A4 A5].freeze

  class << self
    attr_accessor :api_key

    def configure
      yield self
    end

    def create_job(url, page_size: 'A4')
      validate_page_size!(page_size)
      perform_request(:post, :create_job, url: url, page_size: page_size)
    end

    def show_job(id)
      perform_request(:get, :show_job, id)
    end

    def download_pdf(url, page_size: 'A4')
      validate_page_size!(page_size)
      perform_request(:post, :download_pdf, url: url, page_size: page_size)
    end

    private

    def http_client
      @http_client ||= HTTP.basic_auth(user: api_key, pass: '')
    end

    def perform_request(method, endpoint_name, **args)
      url = build_url(endpoint_name, **args)
      if endpoint_name == :download_pdf
        response = http_client.request(method, url, json: args, headers: { 'Content-Type' => 'application/pdf' })
      else
        response = http_client.request(method, url, json: args)
      end
      validate_response!(response)
    end

    def build_url(endpoint_name, **args)
      format(ENDPOINTS[endpoint_name], **args)
    end

    def validate_response!(response)
      # raise Paperplane::Error, response.parse['message'] if response.status >= 400
      response.parse
    end

    def validate_page_size!(page_size)
      raise ArgumentError, "Invalid page size '#{page_size}'" unless PAGE_SIZES.include?(page_size)
    end
  end
end