module Tradesies
  class Candlestick
    attr_reader :price, :ema, :cci, :bands
    
    def initialize(options)
      @price = options[:price]
      @ema = options[:ema] || 0
      @cci = options[:cci] || 0
      @bands = options[:bands] || 0
    end
    
    def outside_bands
      below_lower_band || above_upper_band 
    end
    
    def activated_cci?
	    @cci if @cci >= 75 || @cci <= -75 
    end

    def extreme_cci?
      @cci if @cci >= 150 || @cci <= -150
    end
    
    private

    def below_lower_band
      :lower if @price < @bands[:lower_band] 
    end

    def above_upper_band
      :upper if @price > @bands[:upper_band]
    end

  end
  
  class Switch < Candlestick
    attr_reader :orientation, :length, :coverage
    
    def initialize(options)
      @orientation = options[:orientation]
      @length = options[:length]
      @coverage = options[:coverage]
      super(options)
    end 
    
    def middle_dev
      ( @price - sma ) / sma
    end
 
    private
 
    def sma
      @bands[:middle_band]
    end

  end
end