require "./lib/tasks/url_reader"
require "./lib/tasks/status_checker"
require "./lib/tasks/stats_logger"
require "./lib/tasks/printer"

WORKERS = 2
url_stream = Channel(String).new # Channel, with that type it receives
result_stream = Channel({String, Int32 | Exception}).new
stats_stream = Channel(Array({String, Stats::UrlInfo})).new

UrlReader.run("./urls.yml", url_stream)
WORKERS.times {
  StatusChecker.run(url_stream, result_stream)
}
StatsLogger.run(result_stream, stats_stream)
Printer.run(stats_stream)

sleep
# puts get_urls.call.map(&get_status).join("\n") # Shortcut for map { |url| get_status.call(url) }
puts "Hello Crystal"
