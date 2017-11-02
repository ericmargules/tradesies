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
			balance = @wallet.balance * 0.95
			trade_count = @trades.length * 0.03
			lowest_trade = @trades.sort{ |v1, v2| (v1.close_price * v1.units) <=> (v2.close_price * v2.units) }.first
			lowest_trade * 0.02
			balance + trade_count + lowest_trade
		end

		def random_gene
			@chromosome.to_a.sample(1).to_h
		end

	end

	class Trainer_Coach
		# The trainer coach will be in charge of creating generations of trainer individuals, 
		# measuring their fitness, then breeding them, mutating as necessary and kicking off
		# the next generation.
		def initialize
			@history = []
			@current_population = []
		end

		def new_generation(population)
			population.times { @current_population << Trainer_Individual.new }
		end
		
		def mutate(gene)
		end

		def breed(individual1, individual2)
			chromosome = {}
			random = individual1.random_gene
			key = random.keys[0]
			chromesome[key] = random[key] if !chromosome[key]

			child = Trainer_Individual.new
		end

		def pair
		end
	end
end