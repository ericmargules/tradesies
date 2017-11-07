require_relative 'chart'
require_relative 'strategy'

module Tradesies
	class Historic_Test
		attr_reader :chart, :strategy
		
		def initialize(argv = [])
			@chart = Chart.new("USDT_BTC", 300)
			@strategy = Strategy.new(default_hash)
		end

		def test_strategy
			@chart.data.each { |candlestick| @strategy.process(candlestick) } 
			puts @strategy.wallet.balance
		end

		def default_hash
			{
			:stop_loss_threshold=>0.82, 
			:extreme_low_cci=>-79, 
			:cci_constant=>0.042, 
			:depressed_cci=>-56, 
			:extreme_high_cci=>384, 
			:elevated_cci=>200, 
			:ema_period=>16, 
			:bollinger_band_period=>4}
			}
		end

	end
end