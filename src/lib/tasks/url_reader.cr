require "yaml"

module UrlReader
  def self.run(urls_file, url_stream)
    spawn do # Create a fiber
      get_urls(urls_file).each { |url|
        url_stream.send(url) # Sends each URL to the channel
      }
    end
  end

  private def self.get_urls(urls_file)
    File.open("./urls.yml") do |file|
      YAML.parse(file)["urls"].as_a.map(&.as_s) # Shortcut for map { |url| url.as_s }
    end
  end
end
