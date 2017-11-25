module Tradesies
	class Runner
		def initialize(argv)
			@options = Options.new(argv)
			@connect = GDAXConnect.new(@options)
			@logger = Logger.new
			@indicator = Indicator.new
			@strategy = Strategy.new(@connect, @logger, @indicator)
		end
	end
end

# create options
# create connect
# create strategy
# establish heartbeat 