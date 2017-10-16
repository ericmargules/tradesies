module Tradesies
	class Indicator

		def sma(data, period)
			period = data.length if period > data.length
			data[(0-period)..-1].inject(:+) / Float(period)
		end

		def ema(data, period, initial = 0, weight = 0)
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

		# ema/sma info from http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:moving_averages
		# test data: [22.27, 22.19, 22.08, 22.17, 22.18, 22.13, 22.23, 22.43, 22.24, 22.29, 22.15, 22.39, 22.38, 22.61, 23.36, 24.05, 23.75, 23.83, 23.95, 23.63] 

	end
end