require 'sinatra/base'
require 'pony'
require 'json'
require 'pry'

class JungleFarmsApp < Sinatra::Application

	#filters for all
	before do
		request.body.rewind
		@request_json = JSON.parse request.body.read
		puts "hi, I am in before of all"
	end

	#filters for each
	before '/accounts' do
		#authenticate!
		puts "hi, I am in before of accounts"
	end
		
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

		#fetch top 3 nearest stores based on GPS locations from Google maps
	end
	
	get '/vendors/:retailer_id/search.?:format?', :host_name => /^admin\./ do
		#json
		"Hello #{params['format']}!"
	
		"Hello #{params['retailer_id']}!, #{params['auto_off']}, #{params['categories']}, #{params['include_subcategory']}, #{params['limit']}, #{params['metadata']}, #{params['offset']}, #{params['order_by']}, #{params['sort_order']}, #{params['web_online']}"
	
		#order_by should be say THC levels
		#sort_order to be desc as we fetching store with highest THC level
		#get and total prices of first 3 products from store 1 and save in say var price_store_1[0], [1], [2] and its thc_1[0][1][2]
		#get and total prices of first 3 products from store 2 and save in say var price_store_2[0], [1], [2] and its thc_2[0][1][2]
		#get and total prices of first 3 products from store 3 and save in say var price_store_3[0], [1], [2] and its thc_3[0][1][2]

		#NR - total the price for thc_x[0] and check if it exceeds $50, if not return these 3 products from the 3 different stores
		#NR - total the price for thc_x[0] and check if it exceeds $50, if not return these 3 products from the 3 different stores
	
		#calculate price_per_thc_x[0][1][2] for each products (9 in this case)
		#take the least price_per_thx from the three different stores and iterate until the price doesn't exceed $50
		#return the result which is 3 products the user can get for $50 with highest THC level
	end



	#handlers
	post '/accounts' do
	#get '/accounts' do
		puts "hi, I am in post accounts"
		redirect '/sessions'
	end
	
=begin
	post '/accounts' do
		#request.body
		#binding.pry	
		#request.body['email_address']
		
		#send activation email
		Pony.mail(:to => @request_json['email_address'], :from => 'ragavendra.bn@linuxflavour.com', :subject => 'Email verification', :body => 'Click here to activate your account')
	end
=end

	post '/sessions' do
		puts "hi, I am in post sessions"
		request.body
	end

enable :sessions

	get '/sessions' do
		  
		session['counter'] ||= 0
		session['counter'] += 1
		"You've hit this page #{session['counter']} times!" 
		
		puts "hi, I am in get sessions for #{session['counter']} times!"
	end

	get '/' do
		haml :index
		"Welcome to JungleFarms"
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
