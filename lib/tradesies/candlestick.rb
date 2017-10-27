module Tradesies
  class Candlestick
    attr_reader :price, :high, :low, :ema, :cci, :bands
    
    def initialize(options)
      @price = options[:price]
      @high = options[:high]
      @low = options[:low]
      @ema = options[:ema] || 0
      @cci = options[:cci] || 0
      @bands = options[:bands] || 0
    end
    
    def outside_bands
      ( below_lower_band || above_upper_band ) if @bands != 0
    end

    def depressed_cci?(cci = -100)
      @cci <= cci
    end

    def elevated_cci?(cci = 100)
      @cci >= cci
    end

    def extremely_high_cci?(cci = 200)
      @cci >= cci
    end

    def extremely_low_cci?(cci = -200)
      @cci <= cci
    end
    
    private

    def below_lower_band
      :lower if @price < @bands[:lower_band] 
    end

    def above_upper_band
      :upper if @price > @bands[:upper_band]
    end
  
  end
  
  class Reversal < Candlestick
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