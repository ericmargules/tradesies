require_relative 'logger'

module Tradesies
	class Strategy
		attr_reader :prices, :trades, :candlesticks, :smas, :emas, :ccis
		
		def initialize
			@output = Logger.new
			@indicator = Indicator.new
			@trades = []
			@prices = []
			@current_price = ""
			@max_trades = 1

			# Here be indicators
			@candlesticks = []
			@smas = []
			@emas = []
			@ccis = []
		end

		def consume(candlestick)
			@candlesticks << candlestick.select{|k,v| /high|low|close/.match(k) }
			@current_price = candlestick["weightedAverage"]
			@prices << @current_price

			decode(candlestick) if @prices.length >= 24

			@output.log("Price: #{@current_price}")
		end

		private

		def decode(candlestick)
			@smas << @indicator.sma(@prices, 24)
			@emas << @indicator.ema(@prices, 4)
			@ccis << @indicator.cci(@candlesticks, 20)
		end
	end
end