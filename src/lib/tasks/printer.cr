require "tablo"

module Printer
  def self.run(stats_stream)
    spawn do
      loop do
        data  = stats_stream.receive.map { |(k, v)|
          [k, v[:success], v[:failure]]
        }

        table = Tablo::Table.new(data) do |t|
          t.add_column("Url", width: 36) { |n| n[0] }
          t.add_column("Success") { |n| n[1] }
          t.add_column("Failure") { |n| n[2] }
        end

        puts table
      end
    end
  end
end
