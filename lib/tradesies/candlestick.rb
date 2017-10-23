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
      below_lower_band || above_upper_band 
    end
    
    def activated_cci?
       low_cci(-75) || high_cci(75)
    end

    def extreme_cci?
       low_cci(-150) || high_cci(150)
    end

    def stop_loss?
      @bands[:middle_band] >= ema
    end
    
    private

    def below_lower_band
      :lower if @price < @bands[:lower_band] 
    end

    def above_upper_band
      :upper if @price > @bands[:upper_band]
    end

    def low_cci(cci)
      :low if @cci <= cci
    end

    def high_cci
      :high if @cci >= cci
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