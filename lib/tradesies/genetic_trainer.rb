module Tradesies
	class Trainer

		def initialize
			@chromosome = chromosome 
		end

		def chromosome
			{
				:elevated_cci = rand(25..200),
				:depressed_cci = rand(-200..-25),
				:extreme_high_cci = rand(50..500),
				:extreme_low_cci = rand(-50..-500),
				:ema_period = rand(4..50),
				:cci_constant = rand(0.01..0.05).round(3),
				:bollinger_band_period = rand(4..50),
				:stop_loss_threshold = rand(0.75..0.99).round(2)
			}
		end

	end
end