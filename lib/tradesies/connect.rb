require 'httparty'
require_relative 'options'

module Tradesies
	class GDAXConnect
		attr_reader :options

		def initialize(argv = [])
			@options = Options.new(argv)
	        @api_key = @options.api_key
			@api_secret = @options.api_secret
			@base_url = @options.base_url || "https://api.gdax.com"
		end

		def get_public(url, opts = {})
			result = HTTParty.get(url, opts)
			result.parsed_response
		end

		def ticker
			url = "#{@base_url}/products/#{@options.pair}/ticker"
			get_public(url)
		end

		def orderbook(opts = {})
			opts = {query: {"level" => "#{opts}"} } if opts.class == Fixnum
			url = "#{@base_url}/products/#{options.pair}/book"
			get_public(url, opts)
		end

	end

end