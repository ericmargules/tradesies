require 'httparty'

module Tradesies
	class Chart
		attr_reader :data

		def initialize(pair = "BTC_XMR", period = 300, start_time = 1491048000, end_time = 1491591200)
			@url = 'https://poloniex.com/public'
			@pair = pair
			@period = period
			@start_time = start_time
			@end_time = end_time	
			@data = HTTParty.get(@url, options)
		end

		private

		def options
			{ query: {"command" => "returnChartData", 
						"currencyPair" => @pair, 
						"start" => @start_time,
						"end" => @end_time,
						"period" => @period } }
		end

	end
end	