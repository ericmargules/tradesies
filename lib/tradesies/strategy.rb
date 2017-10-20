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
			# Candlestick initialization hash options:
			# price, ema, cci, bands(hash)

			# Switch initialization hash options:
			# orientation, length, coverage
			
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

def inside_bands?
	above_lower_band? && below_upper_band?
end

def above_lower_band?
	@current_price > @bbs.last[:lower_band]
end

def below_upper_band?
	@current_price < @bbs.last[:upper_band]
end

# *Whether significant peak or nadir in price has occured
def switch?
	if @prices[-1] > @prices[-2]
		@prices[-3] > @prices[-2]
		return (:>)
	elsif @prices[-1] < @prices[-2]
		@prices[-3] < @prices[-2]
		return (:<)
	else
		false
	end
end

# *When CCI enters and exits activation and extreme levels
def activated_cci?
	@ccis.last += 75 || @cci.last -= -75 
end

def extreme_cci?
	@ccis.last += 150 || @cci.last -= -150
end

# Simple Strategy
# If price closes outside the band, trade after two closes within the band. 

# Advanced Strategy

# If price closes outside the bands, check for extreme_cci. 
# If cci is extreme, consider trading. Otherwise wait until 
# the next switch. If it closes within the band, consider trading. 
# Otherwise, when the price approaches the middle band, check 
# the CCI. If the CCI is activated, trade when it goes out of
# activation. Otherwise trade when the price reverses after a 
# trend, buy and hold until next time price crosses and reenters
# a band.

# Test whether price closes outside band.
# If so, identify if the price is higher or lower than the bands.
# Check for extreme CCI.
# If CCI is extreme, trade if possible next close within upper band
# If CCI is not extreme, activate switch-watch and band-watch
# On next switch, test whether price closes outside bands.
# If not, make possible trade.
# If so, test whether price falls outside opposite band.
# If so, make possible sale.

# switch_watch (whenever trade occurs, deactivate switch_watch)
	# Test whether close is switch.
		# If so, test whether switch closes inside bands.
			# If so, test whether band_watch is activated.
				# If so, test whether switch occurs with activated CCI.
					# If so, make possible trade next close with deactivated CCI, deactivate switch_watch.
					# If not, check whether switch happens on other side of middle band.
						# If so, make possible trade, deactivate switch_watch.
						# If not, do nothing.
				# If not, make possible trade, deactivate switch_watch.
			# If not, make possible trade, deactivate switch_watch, activate band_watch.
		# If not, do nothing.

# band_watch (on band_watch activation, activate switch_watch)
	# Test whether close is a switch.
		# If so, test whether switch occurs inside bands.
			# If so, test whether switch has same orientation as band_watch.
				# If so, make possible trade, deactivate band_watch.
				# If not, do nothing.
			# If not, test whether switch occurs on same side as previous band break.
				# If so, make possible trade.
				# If not, make possible trade, deactivate band_watch.
		# If not, do nothing. 

# *Noteworthy characteristics of last switch
def slope_length(operator)
	index = -2
	length = 0
	while @prices[index.pred].send(operator, @prices[index])
		length += 1
		index -= 1
	end
	length
end

# *Orientation of switch
def orientation
	return :peak
	return :nadir
end

def slope_coverage(length)
	@prices[-2] - @prices[-2 - length]
end

def significant_switch?()
	# What constitutes a significant switch?
	# Length >= 4
	# Coverage >= (Upper Bollinger Band - Lower Bollinger Band) / 2
end

# *Occurrence of resistance or support bands
	# examine last couple switchs
	# measure whether their prices are within a certain range of one another
# *When a resistance or support band has been broken