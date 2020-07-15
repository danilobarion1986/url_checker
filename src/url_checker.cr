require "http/client"
require "yaml"
require "tablo"

# Create 2 Procs
get_urls = ->{
  File.open("./urls.yml") do |file|
    YAML.parse(file)["urls"].as_a.map(&.as_s) # Shortcut for map { |url| url.as_s }
  end
}
# crystal syntax for parameter with type -> param : Type
get_status = ->(url : String) {
  begin
    response = HTTP::Client.get(url)
    {url, response.status_code}               # Crystal Tuple
  rescue e : Exception | Socket::ConnectError # Union types
    {url, e}
  end
}

# Concurrent processing
#
#                  [channel]                   [channel]
# url_generator ->  [url] ---> worker_1 ---> [(URL, code)]
#                         \___ worker_2 ___/
url_stream = Channel(String).new # Channel, with that type it receives
result_stream = Channel({String, Int32 | Exception}).new

spawn do # Create a fiber
  get_urls.call.each { |url|
    url_stream.send(url) # Sends each URL to the channel
  }
end

# 2 workers
2.times {
  spawn do  # One fiber for each worker
    loop do # Each worker keeps listening to new message that comes to the channel...
      url = url_stream.receive
      result = get_status.call(url)
      result_stream.send(result) # ...and after processing it, then sends the result to the second channel
    end
  end
}

# Hash key is a String and the values are named tuples -> {name: Type, other_name: OtherType}
stats = Hash(String, {success: Int32, failure: Int32}).new({success: 0, failure: 0}) # Default value passed to Hash#new

# Printer: prints the result to the STDOUT
loop do
  url, result = result_stream.receive # receive a return for the second channel
  url_current_value = stats[url]

  case result
  when Int32
    if result < 400
      stats[url] = {
        success: url_current_value[:success] + 1, # Updates the success value on the tuple
        failure: url_current_value[:failure],     # Updates the failure value on the tuple
      }
    else
      stats[url] = {
        success: url_current_value[:success],
        failure: url_current_value[:failure] + 1,
      }
    end
  when Exception
    stats[url] = {
      success: url_current_value[:success],
      failure: url_current_value[:failure] + 1,
    }
  end

  data = stats.map { |k, v|
    [k, v["success"], v["failure"]]
  }

  table = Tablo::Table.new(data) do |t|
    t.add_column("Url", width: 36) { |n| n[0] }
    t.add_column("Success") { |n| n[1] }
    t.add_column("Failure") { |n| n[2] }
  end

  puts table
end

# Unreachable
puts get_urls.call.map(&get_status).join("\n") # Shortcut for map { |url| get_status.call(url) }
puts "Hello Crystal"
