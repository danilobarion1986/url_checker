require "http/client"

module StatusChecker
  def self.run(url_stream, url_status_stream)
    spawn do  # One fiber for each worker
      loop do # Each worker keeps listening to new message that comes to the channel...
        url = url_stream.receive
        result = get_status(url)
        url_status_stream.send(result) # ...and after processing it, then sends the result to the second channel
      end
    end
  end

  private def self.get_status(url : String)
    response = HTTP::Client.get(url)
    {url, response.status_code}               # Crystal Tuple
  rescue e : Exception | Socket::ConnectError # Union types
    {url, e}
  end
end
