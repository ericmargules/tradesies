require_relative 'logger'
require_relative 'indicator.rb'
require_relative 'wallet'

module Tradesies
	class Strategy
		attr_reader :prices, :trades, :candlesticks, :smas, :emas, :ccis, :wallet

		def initialize
			@output = Logger.new
			@indicator = Indicator.new
			@wallet = Wallet.new(500.0)
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
				if sell?
					@output.log(open_trades[-1].sell(@current_price)) 
					@wallet.balance = (open_trades[-1].close_price * open_trades[-1].units)
					@output.log(@wallet.balance.to_s)
				end
			end
			if open_trades.length < @max_trades
				if buy?
					@trades << Trade.new(@current_price, @wallet.balance) 
					@wallet.balance = 0
					@output.log(@trades[-1].show_trade)
				end
			end
		end

		def buy?
			higher_sma? || (downward_ema? && @ccis[-1] > -100)
		end

		def sell?
			lower_sma? || (upward_ema? && @ccis[-1] < 100)
		end

		def lower_sma?
			@smas[-1] < @emas[-1]
		end

		def higher_sma?
			@smas[-1] > @emas[-1]
		end

		def upward_ema?
			emas[-3] < emas[-2] && emas[-2] < emas[-1]
		end

		def downward_ema?
			emas[-1] < emas[-2] && emas[-2] < emas[-3]
		end

	end
end