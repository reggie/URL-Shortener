require 'rubygems'
require 'sinatra'
require 'mongo'
require 'erb'

include Mongo

configure do
	client = MongoClient.new
	db = client['url-database']
	$urls = db.create_collection('short-urls')
end

def toLetter num
	letters = ("a".."z").to_a
	return letters[num - 10]
end

def toBase36 num
	curr = num % 36
	
	if curr > 9
		id = toLetter(curr)
	else
		id = curr.to_s
	end

	while num >= 36
		num /= 36
		curr = num % 36
		if curr > 9
			id += toLetter(curr)
		else
			id += curr.to_s
		end
	end
	return id.reverse
end

get '/' do
	erb :index, :locals => {:submit => false}
end

post '/' do
	id  = 0
	original = params[:url]
	current = $urls.find({ "original" => original})
	if current.count == 0
		count = $urls.find().count
		id = toBase36(count)
		$urls.insert({"id" => id, "original" => original})
	else
		id = current.to_a[0]['id']
	end
	erb :index, :locals => {:submit => true, :url => id, :path => request.url }
end

get '/:id' do
	original = $urls.find({"id" => params[:id]})

	if original.count == 0
		redirect "/"
	else	
		destination = original.to_a[0]['original']
		redirect "#{destination}"
	end
end

not_found do
	redirect '/'
end

error do
	redirect '/'
end
