# frozen_string_literal: true

RSpec.describe Paperplane do
  let(:api_key) { 'test_api_key' }
  let(:url) { 'https://example.com' }
  let(:page_size) { 'A4' }
  let(:job_id) { '12345' }

  before do
    Paperplane.configure do |config|
      config.api_key = api_key
      config.logger.level = Logger::FATAL
    end
  end

  describe '.download_pdf' do
    it 'downloads a PDF' do
      stub_request(:post, Paperplane::ENDPOINTS[:download_pdf])
        .with(basic_auth: [api_key, ''], body: { url: url, page_size: page_size })
        .to_return(status: 200, body: 'pdf_content')

      response = Paperplane.download_pdf(url)
      expect(response).to eq('pdf_content')
    end

    it 'raises an error when the request fails' do
      stub_request(:post, Paperplane::ENDPOINTS[:download_pdf])
        .with(basic_auth: [api_key, ''], body: { url: url, page_size: page_size })
        .to_return(status: 400, body: 'Bad Request')

      expect { Paperplane.download_pdf(url) }.to raise_error(Paperplane::Error, /Failed to download PDF/)
    end
  end

  describe '.create_job' do
    let(:job_response) do
      {
        "id" => job_id,
        "url" => url,
        "status" => "queued",
        "done" => false,
        "object" => "job"
      }
    end

    it 'creates a job' do
      stub_request(:post, Paperplane::ENDPOINTS[:jobs])
        .with(basic_auth: [api_key, ''], body: { url: url, page_size: page_size })
        .to_return(status: 200, body: job_response.to_json, headers: { 'Content-Type' => 'application/json' })

      response = Paperplane.create_job(url)
      expect(response).to eq(job_response)
    end

    it 'raises an error when the request fails' do
      stub_request(:post, Paperplane::ENDPOINTS[:jobs])
        .with(basic_auth: [api_key, ''], body: { url: url, page_size: page_size })
        .to_return(status: 400, body: 'Bad Request')

      expect { Paperplane.create_job(url) }.to raise_error(Paperplane::Error, /Failed to create job/)
    end
  end

  describe '.show_job' do
    let(:job_response) do
      {
        "id" => job_id,
        "url" => url,
        "status" => "queued",
        "done" => false,
        "object" => "job"
      }
    end

    it 'shows a job' do
      stub_request(:get, "#{Paperplane::ENDPOINTS[:jobs]}/#{job_id}")
        .with(basic_auth: [api_key, ''])
        .to_return(status: 200, body: job_response.to_json, headers: { 'Content-Type' => 'application/json' })

      response = Paperplane.show_job(job_id)
      expect(response).to eq(job_response)
    end

    it 'raises an error when the request fails' do
      stub_request(:get, "#{Paperplane::ENDPOINTS[:jobs]}/#{job_id}")
        .with(basic_auth: [api_key, ''])
        .to_return(status: 404, body: 'Not Found')

      expect { Paperplane.show_job(job_id) }.to raise_error(Paperplane::Error, /Failed to show job/)
    end
  end
end
