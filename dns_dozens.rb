require "rubygems"
require "dozens"
require "uri"

dns(:dozens) {|address, params|
	name = if params["host"]
		"#{params["host"]}.#{params["domain"]}"
	else
		params["domain"]
	end

	api = Dozens::API.new(params["user"], params["key"])

	api.authenticate

	record = api.records(URI::escape(params["domain"]))["record"].find { |_|
		[
			_["name"] == name,
			_["type"] == "A",
		].all?
	}

	if !record
		throw "そんなレコードあらへん"
	end

	api.update_record(record["id"], "content" => address)
}
