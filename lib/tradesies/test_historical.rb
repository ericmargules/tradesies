require_relative 'chart'
require_relative 'strategy'

module Tradesies
	class Historic_Test
		attr_reader :chart
		
		def initialize(argv = [])
			@chart = Chart.new("BTC_XMR", 300, 1507593600, 1507766400).data
			@strategy = Strategy.new
		end

		def test_strategy
			@chart.each { |candlestick| @strategy.consume(candlestick) } 
		end
	end
end