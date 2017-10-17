require_relative 'connect'

module Tradesies 
	class Ticker < KrakenConnect

		def get_point(opts = {})
			opts['pair'] = @options.pair
			get_public("Ticker", opts)
		end

		private

		def log(point)
			puts "The latest price of BTC in USD is: #{point["result"]["XXBTZUSD"]["c"][0]}"
		end

	end
end