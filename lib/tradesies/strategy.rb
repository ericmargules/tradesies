require_relative 'logger'
require_relative 'indicator'
require_relative 'wallet'
require_relative 'candlestick'

module Tradesies
	class Strategy
		attr_reader :trades, :candlesticks, :wallet

		def initialize
			@output = Logger.new
			@indicator = Indicator.new
			@wallet = Wallet.new(500.0)
			@trades = []
			@candlesticks = []
			@current_price = ""
			@max_trades = 1
			@flag = :false
		end

		def process(candlestick)
			@current_price = candlestick["close"]
			switch = enough_for_switch? ? switch? : []
			options_hash = build_options_hash(candlestick, switch)
			candle = options_hash[:orientation] ? Switch.new(options_hash) : Candlestick.new(options_hash)
			@candlesticks << candle
			# eval_positions if @prices.length >= 30

			@output.log("Price: #{@current_price}")
		end

		private

		def eval_positions
			# Check for buy/sell flag		
			if @flag 
				return send(@flag) if @candlesticks.last.outside_bands == false
			end

			# Sell on stop_loss
			return sell if open_trades.any && @candlesticks.last.stop_loss?
			

			# Set flag based on CCI
			set_flag

			# no flag set? test if near/past the middle band and the opposite orientation as the last band break

			# if switch
			# test if inside bands
				# Trade if band_flag is active and switch orientation is opposite to band_flag's orientation and switch is close to middle band.
				# Trade if band_flag is active and switch orientation is equal to band_flag's orientation.

			


			# At this point, need to rely on candlestick to relay information about status of chart
			# for strategy to parse and decide upon.

			# if open_trades.any? 
			# 	if sell?
			# 		@output.log(open_trades[-1].sell(@current_price)) 
			# 		@wallet.balance = (open_trades[-1].close_price * open_trades[-1].units)
			# 		@output.log(@wallet.balance.to_s)
			# 	end
			# end
			# if open_trades.length < @max_trades
			# 	if buy?
			# 		@trades << Trade.new(@current_price, @wallet.balance) 
			# 		@wallet.balance = 0
			# 		@output.log(@trades[-1].show_trade)
			# 	end
			# end
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

		# Options_Hash Methods
		def build_options_hash(candlestick, switch)
			# Hash Options
			# Candlestick: price, ema*, cci*, bands(hash)*
			# Switch: orientation, length, coverage
			# *optional
			options_hash = {}
			options_hash[:price] = candlestick["close"]
			options_hash[:high] = candlestick["high"]
			options_hash[:low] = candlestick["low"]
			if enough_candles?
				options_hash[:sma] = @indicator.sma(prices, 20)
				options_hash[:ema] = @indicator.ema(prices, 4) 
				options_hash[:cci] = @indicator.cci(@candlesticks, 20)
				options_hash[:bands] = @indicator.bands(prices, 20)
			end
			if switch.any?
				options_hash[:orientation] = switch[0]
				options_hash[:length] = switch[1]
				options_hash[:coverage] = slope_coverage(switch[1])
			end
			options_hash
		end

		def prices 
			@candlesticks.map{ |candle| candle.price }
		end

		def bands
			@candlesticks.map{ |candle| candle.bands }
		end

		def enough_candles?
			@candlesticks.length > 19
		end

		def enough_for_switch?
			@candlesticks.length > 21
		end

		# Switch Recognition Methods
		def switch?
			result = []
			{:> => :peak, :< => :nadir}.each do |op, val|
				result = val, slope_length(op) if ( staggered?(op) && ( long_enough?(op) || steep_enough(slope_length(op)) ) )
			end
			result
		end

		def staggered?(operator)
			if @candlesticks.length >= 2
				@current_price.send(operator, @candlesticks.last.price) &&
				@candlesticks[-2].price.send(operator, @candlesticks.last.price)
			end
		end
			
		def long_enough?(operator)
			slope_length(operator) > 3
		end	 

		def steep_enough(length)
			slope_coverage(length) > ( @candlesticks.last.bands[:upper_band] - @candlesticks.last.bands[:lower_band] ) * 0.35
		end

		def slope_length(operator)
			index = -1
			length = 0
			while @candlesticks[index.pred].price.send(operator, @candlesticks[index].price)
				length += 1
				index -= 1
			end
			length
		end

		def slope_coverage(length)
			@candlesticks[-1].price - @candlesticks[-1 - length].price
		end

		# Flag-Setting Methods
	    def set_flag
	    	if @candlesticks.last.outside_bands?
		    	@candlesticks.last.outside_bands == :upper ? set_sell_flag : set_buy_flag
		    end
	    	if @candlesticks.last.extreme_cci? 
	    		@candlesticks.last.extreme_cci? == :high ? set_sell_flag : set_buy_flag
	    	end
	    end
	    
	    def set_buy_flag
	    	@flag = :buy if open_trades.count < @max_trades
	    end
	    
	    def set_sell_flag
	    	@flag = :sell if open_trades.any?
	    end

	   	def open_trades
	   		@trades.select{|trade| trade.status == :open }
	   	end

	end
end

# Need ways to measure:
# *Occurrence of resistance or support bands
	# examine last couple switchs
	# measure whether their prices are within a certain range of one another
# *When a resistance or support band has been broken

# Strategy

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