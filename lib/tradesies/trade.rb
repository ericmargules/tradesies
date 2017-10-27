module Tradesies
    class Trade
        attr_accessor :stop_loss
        attr_reader :open_price, :close_price, :volume, :status, :units

        def initialize(price, volume)
            @open_price = price
            @volume = volume
            @units = (volume / price)
            @close_price = ""
            @status = :open
            @stop_loss = false
        end
    
        def sell(current_price)
            @status = :closed
            @close_price = current_price
            "Trade closed at #{current_price}"
        end
      
        def show_trade
            trade_status = "Status: #{@status}; Opening Price: #{@open_price}"
            trade_status + "; Closing Price: #{@close_price}; Profit: #{@close_price - @open_price}" if @status == :closed
            trade_status
        end
     
    end
end
