module Tradesies
	class Indicator

		def sma(data, period) #Simple Moving Average
			period = data.length if period > data.length
			data[(0-period)..-1].inject(:+) / Float(period)
		end

		def ema(data, period, initial = 0, weight = 0) #Exponential Moving Average
			if initial == 0
				initial = sma(data[0..(data.length - period.next)], period) 
			 	weight = (2 / (Float(period) + 1))
			end
			if period == 0
				initial
		 	else
			 	period -= 1
				ema_data = ema(data[0..-2], period, initial, weight)
				(data[-1] - ema_data) * weight + ema_data
			end
		end

		def cci(data, period, a = 0.015) #Commodity Channel Index
			# CCI = (Typical Price - 20-period SMA of TP) / (a x Mean Deviation)
			# Constant(a) = 0.015
			( tp(data[-1]) - sma_data(data, period) ) / (a * mean_dev(data, period))
		end
		
		private

		def mean_dev(data, period)
			avg = sma_data(data, period)
			data[(data.length - period)..-1].map{ |point| (tp(point) - avg).abs }.inject(:+) / period
		end

		def tp(point)
			# Typical Price = (High + Low + Close) / 3
			( point["high"] + point["low"] + point["close"] ) / 3
		end

		def sma_data(data, period)
			sma(data.map{|point| tp(point) }, period)
		end

		# EMA/SMA/CCI info from http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:moving_averages
		# EMA test data: [22.27, 22.19, 22.08, 22.17, 22.18, 22.13, 22.23, 22.43, 22.24, 22.29, 22.15, 22.39, 22.38, 22.61, 23.36, 24.05, 23.75, 23.83, 23.95, 23.63] 
		# CCI test data: [{"high" => 24.07, "low" => 23.72, "close" => 23.95}, {"high" => 24.20, "low" => 23.85, "close" => 23.89}, {"high" => 24.04, "low" => 23.64, "close" => 23.67}, {"high" => 23.87, "low" => 23.37, "close" => 23.78}, {"high" => 23.67, "low" => 23.46, "close" => 23.50}, {"high" => 23.59, "low" => 23.18, "close" => 23.32}, {"high" => 23.80, "low" => 23.40, "close" => 23.75}, {"high" => 23.80, "low" => 23.57, "close" => 23.79}, {"high" => 24.30, "low" => 24.05, "close" => 24.14}, {"high" => 24.15, "low" => 23.77, "close" => 23.81}, {"high" => 24.05, "low" => 23.60, "close" => 23.78}, {"high" => 24.06, "low" => 23.84, "close" => 23.86}, {"high" => 23.88, "low" => 23.64, "close" => 23.70}, {"high" => 25.14, "low" => 23.94, "close" => 24.96}, {"high" => 25.20, "low" => 24.74, "close" => 24.88}, {"high" => 25.07, "low" => 24.77, "close" => 24.96}, {"high" => 25.22, "low" => 24.90, "close" => 25.18}, {"high" => 25.37, "low" => 24.93, "close" => 25.07}, {"high" => 25.36, "low" => 24.96, "close" => 25.27}, {"high" => 25.26, "low" => 24.93, "close" => 25.00}, {"high" => 24.82, "low" => 24.21, "close" => 24.46}, {"high" => 24.44, "low" => 24.21, "close" => 24.28}, {"high" => 24.65, "low" => 24.43, "close" => 24.62}, {"high" => 24.84, "low" => 24.44, "close" => 24.58}, {"high" => 24.75, "low" => 24.20, "close" => 24.53}, {"high" => 24.51, "low" => 24.25, "close" => 24.35}, {"high" => 24.68, "low" => 24.21, "close" => 24.34}, {"high" => 24.67, "low" => 24.15, "close" => 24.23}, {"high" => 23.84, "low" => 23.63, "close" => 23.76}, {"high" => 24.30, "low" => 23.76, "close" => 24.20}]

	end
end