# paperplane-rb

A simple gem to interact with the Paperplane PDF API. It just has very basic features that I needed quickly. I'll continue to improve this as I need. Feel free to contribute if you'd like!

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add paperplane

Or add it to your `Gemfile` manually:

```ruby
gem 'paperplane'
```

## Usage

Initialize the library and set your API key(required) and logger(optional).
```ruby
    require 'paperplane'

    Paperplane.configure do |config|
    config.api_key = 'your_paperplane_api_key'
    config.logger = Appsignal::Logger.new("paperplane")
    end
```

You can now call the different methods:
```ruby
    # Download PDF
    url = 'https://en.wikipedia.org/wiki/Airplane'
    output_file = 'example.pdf'
    PaperplaneAPI.download_pdf(url, output_file)

    # Create Job
    response = PaperplaneAPI.create_job(url)
    puts response
    job_id = response['id']

    # Show Job
    job = PaperplaneAPI.show_job(job_id)
    puts job
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nolyoi/paperplane-rb.
