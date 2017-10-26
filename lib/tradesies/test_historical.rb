require_relative 'chart'
require_relative 'strategy'

module Tradesies
	class Historic_Test
		attr_reader :chart, :strategy
		
		def initialize(argv = [])
			@chart = Chart.new("USDT_BTC", 300).data
			@strategy = Strategy.new
		end

		def test_strategy
			@chart.each { |candlestick| @strategy.process(candlestick) } 
			puts @strategy.wallet.balance
		end
	end
end