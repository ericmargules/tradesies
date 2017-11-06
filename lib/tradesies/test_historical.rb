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
			:elevated_cci => 100,
			:depressed_cci => -100,
			:extreme_high_cci => 200,
			:extreme_low_cci => -200,
			:ema_period => 10,
			:cci_constant => 0.015,
			:bollinger_band_period => 20,
			:stop_loss_threshold => 0.98
			}
		end

	end
end