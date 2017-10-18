require_relative 'chart'
require_relative 'strategy'

module Tradesies
	class Historic_Test
		attr_reader :chart, :strategy
		
		def initialize(argv = [])
			@chart = Chart.new("USDT_BTC", 300, 1507957200, 1508130000).data
			@strategy = Strategy.new
		end

		def test_strategy
			@chart.each { |candlestick| @strategy.consume(candlestick) } 
			puts @strategy.wallet.balance
		end
	end
end