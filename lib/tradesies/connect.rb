require 'httparty'
require_relative 'options'

module Tradesies
	class KrakenConnect
		attr_reader :options

		def initialize(argv = [], api_key = nil, api_secret = nil, options = {})
			@options = Options.new(argv)
	        @api_key = api_key
			@api_secret = api_secret
	    	@api_version = options[:version] ||= '0'
			@base_uri = options[:base_uri] ||= 'https://api.kraken.com'
		end

		def get_public(method, opts={})
			url = @base_uri + '/' + @api_version + '/public/' + method
			result = HTTParty.get(url, query: opts)
			result["result"]
		end
	end
end