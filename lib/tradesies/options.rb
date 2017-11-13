require 'optparse'

module Tradesies
	class Options
		DEFAULT_PAIR = 'BTC-USD'
		DEFAULT_INTERVAL = '300'
		attr_reader :pair, :interval, :api_key, :api_secret, :base_url

		def initialize(argv=[])
			@pair = DEFAULT_PAIR
			@interval = DEFAULT_INTERVAL
			@api_key = ""
			@api_secret = ""
			@base_url = false
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

				opts.on("-k", "--api_key api_key", "Key for API") do |api_key|
					@api_key = api_key
				end

				opts.on("-s", "--api_secret api_secret", "Secret for API") do |api_secret|
					@api_secret = api_secret
				end

				opts.on("-u", "--base_url base_url", "Secret for API") do |base_url|
					@base_url = base_url
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