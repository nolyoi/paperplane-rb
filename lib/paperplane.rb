# frozen_string_literal: true

require 'http'
require 'paperplane/config'
require 'paperplane/error'
require 'paperplane/version'

module Paperplane
  ENDPOINTS = {
    download_pdf: 'https://download.paperplane.app/',
    jobs: 'https://api.paperplane.app/jobs'
  }.freeze

  class << self
    attr_writer :config

    def config
      @config ||= Config.new
    end

    def configure
      yield(config) if block_given?
    end

    def client
      @client ||= HTTP.basic_auth(user: config.api_key, pass: '')
    end

    def prepare_params(url, page_size: 'A4')
      params = { url: url, page_size: page_size }
    end

    # Download PDF
    def download_pdf(url, page_size: 'A4')
      params = prepare_params(url, page_size: page_size)
      response = client.post(ENDPOINTS[:download_pdf], form: params)
      raise Paperplane::Error, "Failed to download PDF: #{response.status}" unless response.status.success?
      
      config.logger.info("Downloaded PDF: #{url}")
      response.body.to_s
    end

    # Create Job
    def create_job(url, page_size: 'A4', options: {})
      params = prepare_params(url, page_size: page_size)
      response = client.post(ENDPOINTS[:jobs], form: params.merge(options))
      raise Paperplane::Error, "Failed to create job: #{response.status}" unless response.status.success?

      config.logger.info("Created job for URL: #{url}")
      response.parse
    end

    # Show Job
    def show_job(job_id)
      response = client.get("#{ENDPOINTS[:jobs]}/#{job_id}")
      raise Paperplane::Error, "Failed to show job: #{response.status}" unless response.status.success?

      config.logger.info("Fetched job: #{job_id}")
      response.parse
    end
  end
end