require_relative 'logger'

module Tradesies
	class Strategy

		def initialize
			@output = Logger.new
			@prices = []
			@closes = []
			@trades = []
			@current_price = ""
			@current_close = ""
			@allowable_trades = 1
			@indicators = ""
		end

		def consume(candlestick)
			@current_price = candlestick["weightedAverage"]
			@prices << @current_price
			@output.log("Price: #{@current_price}")
		end
	end
end