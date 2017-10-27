require 'csv'

module Tradesies
	class Chart_Creator

		def self.build_file(data, start_time)
			CSV.open("/home/eric/Documents/ruby/tradesies/lib/tradesies/#{start_time}.csv", "w") do |csv|
				csv << ["Price", "Lower Band", "Middle Band", "Upper Band", "CCI"]
				data.each do |candle|					
					csv << [candle.price, candle.bands[:lower_band], candle.bands[:middle_band], candle.bands[:upper_band], candle.cci] if candle.bands != 0
				end
			end
		end

	end
end