require_relative 'logger'

module Tradesies
	class Strategy
		attr_reader :prices, :trades, :candlesticks, :smas, :emas, :ccis

		def initialize
			@output = Logger.new
			@indicator = Indicator.new
			@trades = []
			@candlesticks = []
			@prices = []
			@current_price = ""
			@max_trades = 1

			# Here be indicators
			@smas = []
			@emas = []
			@ccis = []
		end

		def consume(candlestick)
			@candlesticks << candlestick.select{|k,v| /high|low|close/.match(k) }
			@current_price = candlestick["weightedAverage"]
			@prices << @current_price

			harvest_candlestick if @prices.length >= 24
			eval_positions if @prices.length >= 30

			@output.log("Price: #{@current_price}")
		end

		private

		def harvest_candlestick
			@smas << @indicator.sma(@prices, 24)
			@emas << @indicator.ema(@prices, 4)
			@ccis << @indicator.cci(@candlesticks, 20)
		end

		def eval_positions
			open_trades = @trades.select{|trade| trade.status == :open }
			if open_trades.any? 
				open_trades[-1].sell if sell?
			end
			if open_trades.length < @max_trades
				@trades << Trade.new(@current_price) if buy?
			end
		end

		def buy?
			lower_sma? || (upward_ema? && @ccis[-1] < -100)
		end

		def sell?
			higher_sma? || (downward_ema && @ccis[-1] > 100)
		end

		def lower_sma?
			@sma[-1] < @ema[-1]
		end

		def higher_sma?
			@sma[-1] > @ema[-1]
		end

		def upward_ema?
			emas[-3] < emas[-2] && emas[-2] < emas[-1]
		end

		def downward_ema?
			emas[-1] < emas[-2] && emas[-2] < emas[-3]
		end
	end
end