require 'optparse'

module Tradesies
	class Options
		DEFAULT_PAIR = 'XBTUSD'
		DEFAULT_INTERVAL = '600'
		attr_reader :pair, :interval

		def initialize(argv)
			@pair = DEFAULT_PAIR
			@interval = DEFAULT_INTERVAL
			parse(argv)
		end
		
		def parse(argv)
			OptionParser.new do |opts|
				opts.banner = "Usage: tradesies [ options ]"

				opts.on("-p", "--pair pairs", "Currencies to query") do |pair|
					puts "Test3!"
					@pair = pair
				end

				opts.on("-i", "--interval interval", "Interval for ticker") do |interval|
					@interval = interval
				end

				opts.on('-h', '--help', 'Displays Help') do
					puts opts
					exit
				end

				begin
					arv = ["-h"] if argv.empty?
					opts.parse!(argv)
				rescue OptionParser::ParseError => e
					STDERR.puts e.message, "\n", opts
					exit(-1)
				end
			end
		end
	end
end