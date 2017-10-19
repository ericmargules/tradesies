require_relative 'logger'
require_relative 'indicator.rb'
require_relative 'wallet'

module Tradesies
	class Strategy
		attr_reader :prices, :trades, :candlesticks, :emas, :ccis, :bbs, :wallet

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
			@emas = []
			@ccis = []
			@bbs = []
		end

		def consume(candlestick)
			@candlesticks << candlestick.select{|k,v| /high|low|close/.match(k) }
			@current_price = candlestick["weightedAverage"]
			@prices << @current_price

			harvest_candlestick if @prices.length >= 20
			# eval_positions if @prices.length >= 30

			@output.log("Price: #{@current_price}")
		end

		private

		def harvest_candlestick
			@bbs << @indicator.bbands(@prices, 20)
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

# Need ways to measure:

# *Whether price crossed bands
@price > @indicator.bbands(@prices, 20)
# *Whether peak or nadir in price has occured
def peak?
	if @prices[-1] > @prices[-2]
		@prices[-3] > @prices[-2]
	elsif @prices[-1] < @prices[-2]
		@prices[-3] < @prices[-2]
	else
		false
	end
end
# *Noteworthy characteristics of last peak
# *Occurrence of resistance or support bands
	# examine last couple peaks
	# measure whether their prices are within a certain range of one another
# *When a resistance or support band has been broken
# *When CCI enters and exits activation and extreme levels
def activated_cci?
	@activated_cci = (@ccis.last += 100 || @cci.last -= -100) ? :true : :false 
end

def extreme_cci?
	@extreme_cci = (@ccis.last += 200 || @cci.last -= -200) ? :true : :false
end

# Simple Strategy
# If price closes outside the band, trade after two closes within the band. 

# Advanced Strategy

# If price closes outside the bands, check for extreme_cci. 
# If cci is extreme, consider trading. Otherwise wait until 
# the next peak. If it closes within the band, consider trading. 
# Otherwise, when the price approaches the middle band, check 
# the CCI. If the CCI is activated, trade when it goes out of
# activation. Otherwise trade when the price reverses after a 
# trend, buy and hold until next time price crosses and reenters
# a band.