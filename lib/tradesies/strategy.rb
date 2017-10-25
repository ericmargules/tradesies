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
		end

		def process(candlestick)
			@current_price = candlestick["close"]
			# Only check for reversals after enough data points are gathered
			reversal = enough_for_reversal? ? reversal? : []
			options_hash = build_options_hash(candlestick, reversal)
			candle = options_hash[:orientation] ? Reversal.new(options_hash) : Candlestick.new(options_hash)
			@candlesticks << candle
			
			eval_positions if @candlesticks.length >= 21

			@output.log("Price: #{@current_price}")
		end

		private

		def eval_positions			
			possible_trades.each{ |trade| send(trade, trade_conditions[trade]) }
		end

		# Trade Methods
		def make_trade(action)
			if action == :sell
				@output.log(open_trades[-1].sell(@current_price)) 
				@wallet.balance = (@trades[-1].close_price * @trades[-1].units)
				@output.log(@wallet.balance.to_s)
			end
			if action == :buy
				@trades << Trade.new(@current_price, @wallet.balance) 
				@wallet.balance = 0
				@output.log(@trades[-1].show_trade)
			end
		end

		def buy(args)
			# simple strategy
			make_trade(:buy) if args.any?
			# advanced strategy || rebound(:lower)
		end

		def sell(args)
			#simple strategy
			make_trade(:sell) if args.any?
			# advanced strategy || rebound(:upper)
		end

		# Trade Conditions Methods
		def trade_conditions
			{:buy => [outside_bands_to_inside?(:lower), extreme_reversal_outside_bands(:lower)],
			:sell =>[stop_loss?, outside_bands_to_inside?(:upper), extreme_reversal_outside_bands(:upper)]}			
		end
		
		def rebound(band)
			opposites = {:upper => {:orientation => :nadir, 
									:operator => :<=, 
									:cci => :depressed_cci?}, 
						:lower => {:orientation => :peak, 
									:operator => :>=, 
									:cci => :elevated_cci?}}
			# Last close is reversal
			last_is_reversal? &&
			# Last orientation is opposite of band
			@candlesticks.last.orientation == opposites[band][:orientation] &&
			# Price is at or beyond middle band
			price_near_sma?(opposites[band][:operator]) &&
			# CCI is elevated or extreme
			@candlesticks.last.send(opposites[band][:cci])	
		end

		def stop_loss?
		end

		def extreme_reversal_outside_bands(band)
			pairs = {:upper => :elevated_cci?, :lower => :depressed_cci?}
			last_is_reversal? && 
			@candlesticks.last.send(pairs[band]) && 
			band_break?(-1) == band
		end

		def outside_bands_to_inside?(band)
			inside_bands?(-1) && band_break?(-2) == band
		end

		# Reversal Evaluation Methods
		def band_break?(ind)
			@candlesticks[ind].outside_bands
		end

		def inside_bands?(ind)
			@candlesticks[ind].outside_bands == false
		end

		def last_is_reversal?
			@candlesticks.last.class == Tradesies::Reversal
		end

		# Trade Methods
	   	def open_trades
	   		@trades.select{ |trade| trade.status == :open }
	   	end
		
		def possible_trades
			result = []
			result << :buy if available_buy?
			result << :sell if available_sale?
			result
		end
		
		def available_buy?
			open_trades.count < @max_trades
		end

		def available_sale?
			open_trades.any?
		end

		# Options_Hash Methods
		def build_options_hash(candlestick, reversal)
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
			if reversal.any?
				options_hash[:orientation] = reversal[0]
				options_hash[:length] = reversal[1]
				options_hash[:coverage] = slope_coverage(reversal[1])
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

		def enough_for_reversal?
			@candlesticks.length > 21
		end

		# Reversal Recognition Methods
		def reversal?
			result = []
			{:> => :nadir, :< => :peak}.each do |op, val|
				result = val, slope_length(op) if standard_reversal?(op)
			end
			result = special_rebound_reversal if result.empty?
			result
		end

		def standard_reversal?(operator)
			staggered?(operator) && 
			( slope_grade(operator, 2, 0.3) || slope_grade(operator, 1, 0.45) )
		end

		def staggered?(operator)
			@current_price.send(operator, @candlesticks.last.price) &&
			@candlesticks[-2].price.send(operator, @candlesticks.last.price)
		end
		
		def slope_grade(operator, length, cover)
			long_enough?(operator, length) && steep_enough?(slope_length(operator), cover)
		end

		def long_enough?(operator, const)
			slope_length(operator) > const
		end	 

		def steep_enough?(length, const)
			slope_coverage(length) > ( @candlesticks.last.bands[:upper_band] - @candlesticks.last.bands[:lower_band] ) * const
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
			( @candlesticks[-1].price - @candlesticks[-1 - length].price ).abs
		end

		# Upper Rebound Methods
		def special_rebound_reversal
			upper_rebound? ? [:nadir, slope_length(:>)] : [] 
		end

		def upper_rebound?
			last_band_break == :upper && 
			staggered?(:>) && 
			long_enough?(:>, 1) && 
			price_near_sma?(:<=) 
		end

	   	def last_band_break
	   		@candlesticks.select {|candle| candle.outside_bands }.last.outside_bands
	   	end

		def price_near_sma?(operator)
			@candlesticks.last.price.send(operator, @candlesticks.last.bands[:middle_band])
		end

	end
end

# Need ways to measure:
# *Occurrence of resistance or support bands
	# examine last couple switchs
	# measure whether their prices are within a certain range of one another
# *When a resistance or support band has been broken