require 'sinatra/base'
require 'pony'
require 'json'
require 'pry'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/model'

#Algorithm
#order_by should be say THC levels
#sort_order to be desc as we fetching store with highest THC level
#get and total prices of first 3 products from store 1,2,3 and save in say var price_store_1[0], [1], [2] and its thc_x[0][1][2]
#calculate price_per_thc_x[0][1][2] for each products (9 in this case)
#take the least price_per_thx from the three different stores and iterate until the price doesn't exceed $50
#return the result which is 3 products the user can get for $50 with highest THC level
	
class DuberApp < Sinatra::Application

		
	get '/retailers.?:format?', :host_name => /^admin\./ do
		#json
		"Hello #{params['format']}!"
		
		#WA
		"Hello #{params['state']}!"
	end

	get '/products/geo_search.?:format?', :host_name => /^admin\./ do
		#json
		"Hello #{params['format']}!"
		"Hello #{params['search_text']}!, #{params['gps0']}, #{params['gps1']}"

	end
	
	get '/vendors/:retailer_id/search.?:format?', :host_name => /^admin\./ do
		#json
		"Hello #{params['format']}!"
	
		"Hello #{params['retailer_id']}!, #{params['auto_off']}, #{params['categories']}, #{params['include_subcategory']}, #{params['limit']}, #{params['metadata']}, #{params['offset']}, #{params['order_by']}, #{params['sort_order']}, #{params['web_online']}"
	end
	
	get '/challenge', :host_name => /^admin\./ do
		
		#check cache if in case someone from the same region searched in the last 20 minutes.
		@models = Model.all
		@models.each do | model |
			time_diff = Time.now - model.updated_at
			if (time_diff <= 20 * 60)	
				if (model.amount.eql?params['amount'] && model.pin_code.eql?params['pin_code'])
					redirect '/results'
				end
			else
				#delete the record
				@model.delete
			end
		end	
		
		# matches "GET /challenge?amount=50&pin_code=V3N3S8"
		"Hello #{params['amount']}!, #{params['pin_code']}"
		
		#fetch top 3 nearest stores based on GPS locations from Google maps say retailer_1, retailer_2 and retailer_3
		#get the 3 nearest retailers
		status, headers, body = call env.merge("PATH_INFO" => '/retailers.json?state=WA')
		retailer[0] = body['retailer_name']
		# add for [1] and [2]
		
		#order_by should be say THC levels
		#sort_order to be desc as we fetching store with highest THC level
		#get and total prices of first 3 products from store 1 and save in say var price_store_1[0], [1], [2] and its thc_1[0][1][2]
		#
		status, headers, body = call env.merge("PATH_INFO" => "/vendors/#{retailer[0]}/search.json?auto_off=web_online&categories%5B%5D=Flowers%25&include_subcategory=false&limit=#{params['amount']}&metadata=1&offset=0&order_by=display_name&sort_order=asc&web_online=true")
		product_name[0][0] = body['product_name']
		product_id[0][0] = body['product_id']
		product_price[0][0] = body['product_price']
		product_ths[0][0] = body['product_ths']
		# do this for product [0][1] and product [0][2]

		#calculate price_per_thc_x[0][1][2] for each products (9 in this case)
		#[store_number][product_number]
		price_per_thc[0][0] = product_price[0][0] / product_ths[0][0]
		price_per_thc[0][1] = product_price[0][1] / product_ths[0][1]
		price_per_thc[0][2] = product_price[0][2] / product_ths[0][2]

		#take the least price_per_thx from the three different stores and iterate until the price doesn't exceed $50
		#return the result which is 3 products the user can get for $50 with highest THC level

		total_price = 0
		3.times do | product |
			3.times do | store |
				break if ((total_price + price_per_thc[store][product]) > 50)
				total_price = total_price + price_per_thc[store][product] 
				#save the product ids
				prod_id[store] = product_id[store][product] 
			end
			#break if total_price > 50
			
			break if ((total_price + price_per_thc[store][product]) > 50)
		end

		#3.times do | product |
		#end
		
		#get current time
		updated_at = Time.now 

		#back end team - lets save it to cache for 20 minutes
		@model = Model.new(params['amount'], params['pin_code'], prod_id, updated_at)

		if @model.save
			redirect '/results'
		else
			"Sorry, there was an error!"
		end
		
		#return the array having the 3 prod ids
		#return prod_id
	end

	get '/results' do
		@models = Model.all
		erb :models
	end

	get '/' do
		erb :index
	end

	get '/haml' do
		haml :index
		"Welcome to Duberex"
	end

	get '/about' do
		haml :about
		"About JungleFarms"
	end
	
	get '/raga/:name' do
		haml :raga
		"Welcome to my page, my name is #{params[:name]}"
	end


	get '/raga/*/hello/*' do
		"You are trying to access with #{params['splat']}"
	end

	#more of an exception handler kind for invalid URL POSTs
	post '/*' do
		request.body
	end

end
