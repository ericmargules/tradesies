require_relative 'chart'

module Tradesies
	class Trainer_Individual

		attr_reader :chromosome

		def initialize(chromosome = nil)
			@chromosome = chromosome || random_chromosome
			mutate
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
			# Figure this shit out
			# Should be almost entirely dependent on ending balance
			# Higher balances should be much more likely to be selected than lower balances
			# Number of trades should be a minor factor.
			# Lowest trade should also be a minor factor.
			return 0 if @trades.length == 0
			balance = @wallet.balance <= 500 ? 0.5 : ( @wallet.balance - 500 ) * 0.95
			
			# Most the number of trades can add to the fitness is (@wallet.balance - 500) * 0.25
			# Ideal is 1 trade. Decreases has trade count increases
			number_of_trades = @trades.length
			trade_count = .5 / number_of_trades
			
			# Most lowest trade can add to fitness is (@wallet.balance - 500) * 0.25
			# Ideal is 500. Decreases as lowest trade decreases
			lowest_trade = @trades.sort{ |v1, v2| (v1.close_price * v1.units) <=> (v2.close_price * v2.units) }.first
			lowest_trade * 0.02

			balance + trade_count + lowest_trade
		end

		def mutate
			@chromosome.each{ |k,v| @chromosome[k] = random_chromosome[k] if rand(1..5) < 2 }
		end

	end

	class Trainer_Coach
		# The trainer coach will be in charge of creating generations of trainer individuals, 
		# breeding them according to fitness, and repeating that process until a specified number
		# of generations has been reached.

		def initialize(charts = [], data_size = 10, currency_pair = "USDT_BTC", interval = 300)
			@charts = charts
			@history = []
			@current_population = []
			build_first_generation(data_size)
			data_size.times{ add_chart(currency_pair, interval) } if @charts.empty?
		end

		def train(number_of_generations)
			number_of_generations.times do
				test_generation
				archive_generation
				new_generation
			end
			puts @history.last.sort{ |i1, i2| i1.fitness <=> i2.fitness }.last.wallet.balance
		end

		def test_generation
			@current_population.each do |individual|
				run_charts(individual)
			end			
		end

		def run_charts(individual)
			@charts.each do |chart|
				individual.process(chart.data)
				close_trades
			end
		end

		def add_chart(currency_pair, interval)
			@charts << Chart.new(currency_pair, interval)
		end

		def build_first_generation(population)
			population.times{ @current_population << Trainer_Individual.new }
		end

		def archive_generation
			@history << @current_population
		end
		
		def new_generation
			@current_population.clear
			while @current_population.length < @history.last.length
				breed(select_breeding_pair)
			end
		end

		def breed(pair)	
			child_chrom1 = pair[0].chromosome.to_a.sample( (pair[0].chromosome.length / 2) ).to_h
			child_chrom2 = {}
			pair[0].chromosome.each{ |k,v| child_chrom2[k] = v if child_chrom1[k] == nil }
			pair[1].chromosome.each{ |k,v| child_chrom1[k] ? child_chrom2[k] = v : child_chrom1[k] = v }
			@current_population << Trainer_Individual.new(child_chrom1)
			@current_population << Trainer_Individual.new(child_chrom2)
		end

		def select_breeding_pair
			pair = [roulette_selection]
			selection = pair[0]
			selection = roulette_selection while selection == pair[0]
			pair << selection
		end

		def roulette_selection
			spin = spin_wheel(@history.last.inject(0){|m, individual| m += individual.fitness })
			winner = ""
			@history.last.sort{ |i1, i2| i1.fitness <=> i2.fitness }.each do |ind|
				if spin > 0 
					spin -= ind.fitness
					winner = ind if spin <= 0 
				end 
			end
			winner 
		end

		def spin_wheel(limit)
			rand(1.0..limit).round(2)
		end

		def close_trades(individual)
			individual.open_trades.each do |trade| 
				trade.sell(individual.current_price)
				individual.wallet.balance = trade.units * individual.current_price
			end
		end
	
	end

end