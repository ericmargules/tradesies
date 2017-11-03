module Tradesies
	class Trainer_Individual

		attr_accessor :chromosome

		def initialize(chromosome = nil)
			@chromosome = chromosome || random_chromosome
		end

		def random_chromosome
			{
				:elevated_cci => rand(25..200),
				:depressed_cci => rand(-200..-25),
				:extreme_high_cci => rand(50..500),
				:extreme_low_cci => rand(-500..-50),
				:ema_period => rand(4..50),
				:cci_constant => rand(0.01..0.05).round(3),
				:bollinger_band_period => rand(4..50),
				:stop_loss_threshold => rand(0.75..0.99).round(2)
			}
		end

		def fitness
			return 500 * 0.95 if @trades.length == 0
			balance = @wallet.balance * 0.95
			trade_count = @trades.length * 0.03
			lowest_trade = @trades.sort{ |v1, v2| (v1.close_price * v1.units) <=> (v2.close_price * v2.units) }.first
			lowest_trade * 0.02
			balance + trade_count + lowest_trade
		end

		def mutate
			@chromosome.each { |k,v| @chromosome[k] = random_chromosome[k] if rand(1..4) < 2 }
		end

	end

	class Trainer_Coach
		# The trainer coach will be in charge of creating generations of trainer individuals, 
		# measuring their fitness, then breeding them, mutating as necessary and kicking off
		# the next generation.

		# Requirements:
		# Create charts that will be fed to individual solutions
		# Create generations to feed into algo
		# Close out open trades after individual solutions complete charts
		# Evaluate fitnesses of individual solutions
		# Breed/mutate solutions
		# Maintain historical record of generations
		# Terminate process at predetermined point or at will.

		def initialize(charts = [])
			@history = []
			@current_population = []
		end

		def new_generation(population)
			population.times { @current_population << Trainer_Individual.new }
		end
		
		def mutate(gene)
		end

		def breed(chrom1, chrom2)	
			child_chrom1 = chrom1.to_a.sample( (chrom1.length / 2) ).to_h
			child_chrom2 = {}

			chrom1.each {|k,v| child_chrom2[k] = v if child_chrom1[k] == nil }
			chrom2.each{ |k,v| child_chrom1[k] ? child_chrom2[k] = v : child_chrom1[k] = v }

			Trainer_Individual.new(child_chrom1), Trainer_Individual.new(child_chrom2)
		end

		def pair
		end

		def close_trades(individual)
			individual.open_trades.each do |trade| 
				trade.sell(individual.current_price)
				individual.wallet.balance = trade.units * individual.current_price
			end
		end
	end
end