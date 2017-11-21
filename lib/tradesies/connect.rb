require 'httparty'
require 'openssl'
require 'base64'
require 'json'
require_relative 'options'

module Tradesies

	class GDAXConnect
		attr_reader :options

		def initialize(argv = [])
			@options = Options.new(argv)
		end

		def get_public(url, opts = {})
			result = HTTParty.get(url, opts)
			result.parsed_response
		end

		def get_private(headers, body, path, method)
			path = @options.base_url + path
			 body.class
			result = method == "GET" ? HTTParty.get( path, :headers => headers, body: body ) : HTTParty.post( path, headers: headers, body: body ) 
			result.parsed_response
		end

		def build_headers(timestamp, signature)
			opts = {}
			opts['Content-Type'] = 'application/json'
			opts["User-Agent"] = "gdax-ruby-client"
			opts["CB-ACCESS-KEY"] = @options.api_key
			opts["CB-ACCESS-TIMESTAMP"] = timestamp
			opts["CB-ACCESS-PASSPHRASE"] = @options.api_passphrase
			opts["CB-ACCESS-SIGN"] = signature
			opts
		end

		def build_signature(body, path, method, timestamp)
			what = "#{timestamp}#{method}#{path}#{body}";
			secret = Base64.decode64(@options.api_secret)
			hash  = OpenSSL::HMAC.digest('sha256', secret, what)
			Base64.strict_encode64(hash)
		end

		# Public API Calls

		def ticker
			url = "#{@options.base_url}/products/#{@options.pair}/ticker"
			get_public(url)
		end

		def orderbook(opts = {})
			opts = {query: {"level" => "#{opts}"} } if opts.class == Fixnum
			url = "#{@options.base_url}/products/#{@options.pair}/book"
			get_public(url, opts)
		end

		# Private API Calls

		def get_accounts
			path = "/accounts"
			method = "GET"
			body = ""
			process_private(body, path, method)
		end

		def get_account(id)
			method = "GET"
			path = "/accounts/#{id}"
			body = ""
			process_private(body, path, method)
		end

		def get_account_history(id)
			method = "GET"
			path = "/accounts/#{id}/ledger"
			body = ""
			process_private(body, path, method)
		end

		def post_market_order(side, amount)
			method = "POST" 
			path = "/orders" 
			body = {
				:product_id => @options.pair,
				:type => "market", 
				:side => side, 
				:funds => amount 
			}
			process_private(body, path, method)
		end

		def get_orders(status)
			path = "/orders"
			method = "GET"
			body = { "status" => status }
			process_private(body, path, method)
		end

		def process_private(body, path, method)
			timestamp = Time.now.to_i.to_s
			body = body.to_json if body.is_a?(Hash)
			signature = build_signature(body, path, method, timestamp)
			headers = build_headers(timestamp, signature)
			get_private(headers, body, path, method)
		end
	
	end

end