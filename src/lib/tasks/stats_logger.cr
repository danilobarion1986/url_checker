require "../stats"

module StatsLogger
  def self.run(url_result_stream, stats_stream)
    spawn do
      stats = Stats.new

      # Printer: prints the result to the STDOUT
      loop do
        url, result = url_result_stream.receive # receive a return for the second channel

        case result
        when Int32
          if result < 400
            stats.log_success(url)
          else
            stats.log_failure(url)
          end
        when Exception
          stats.log_failure(url)
        end

        data = stats.map { |k, v| {k, v} }
        stats_stream.send(data)
      end
    end
  end
end
