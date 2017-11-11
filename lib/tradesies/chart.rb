require 'httparty'

module Tradesies
	class Chart
		attr_reader :data, :start_time, :end_time

		def initialize(pair = "BTC_XMR", period = 300, start_time = nil, end_time = nil )
			@url = 'https://poloniex.com/public'
			@pair = pair
			@period = period
			@start_time = start_time || random_date.to_i
			@end_time = end_time || tomorrow(@start_time)	
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

		def random_date from = Time.local(2017, 6, 1), to = Time.now
		 	result = Time.at(from + rand * (to.to_f - from.to_f))
			result
		end

		def tomorrow(date)
			date + ( 60 * 60 * 24 )
		end
	end
end