module Tradesies
    class Trade
        def initialize(price, volume)
            @open_price = price
            @volume = volume
            @close_price = ""
            @status = :open
            @output = Logger.new
        end
    
        def close(current_price)
            @status = :closed
            @close_price = current_price
            @output.log("Trade closed at #{current_price}")
        end
      
        def show_trade
            trade_status = "Status: #{@status}; Opening Price: #{@open_price}"
            trade_status += "; Closing Price: #{@close_price}; Profit: #{@close_price - @open_price}" if @status == :closed
            @output.log(trade_status)
        end
     
    end
end
