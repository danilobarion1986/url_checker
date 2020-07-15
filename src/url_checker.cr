require "http/client"
require "yaml"

get_urls = ->{
  File.open("./urls.yml") do |file|
    YAML.parse(file)["urls"].as_a.map(&.as_s)
  end
}

get_status = ->(url : String) {
  begin
    puts "calling #{url}"
    response = HTTP::Client.get(url)
    response.status_code
  rescue e : Exception | Socket::ConnectError # Union types
    {url, e}
  ensure
    puts "called #{url}"
  end
}

puts get_urls.call.map(&get_status).join("\n")

puts "Hello Crystal"
