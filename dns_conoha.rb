require "rubygems"
require "net/http"
require "json"
require "uri"

class ConohaResourceNotFound < Exception
end

dns(:conoha) {|address, params|
	def auth(username, password, tenant_id)
		req = {
			"auth": {
				"passwordCredentials": {
					"username": username,
					"password": password, 
				},
				"tenantId": tenant_id
			}
		}

		uri = URI.parse("https://identity.tyo2.conoha.io/v2.0/tokens")

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		post = Net::HTTP::Post.new(uri.request_uri)

		post["Content-Type"] = "application/json"
		post.body = req.to_json

		JSON.parse(http.request(post).body)["access"]["token"]["id"]
	end


	def get_domains(token)
		uri = URI.parse("https://dns-service.tyo2.conoha.io/v1/domains")

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		get = Net::HTTP::Get.new(uri.request_uri)

		get["X-Auth-Token"] = token

		JSON.parse(http.request(get).body)["domains"]
	end


	def get_records(token, domain)
		uri = URI.parse("https://dns-service.tyo2.conoha.io/v1/domains/#{domain["id"]}/records")

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		get = Net::HTTP::Get.new(uri.request_uri)

		get["X-Auth-Token"] = token

		JSON.parse(http.request(get).body)["records"]
	end


	def update_record(token, domain, record, address)
		req = {
			"data": address
		}

		uri = URI.parse("https://dns-service.tyo2.conoha.io/v1/domains/#{domain["id"]}/records/#{record["id"]}")

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		put = Net::HTTP::Put.new(uri.request_uri)

		put["X-Auth-Token"] = token
		put["Content-Type"] = "application/json"
		put.body = req.to_json

		http.request(put)
	end


	def update(token, domain, address)
		target_domain = get_domains(token).find { |_|
			_["name"] == "#{domain}."
		}

                if target_domain == nil
                  throw ConohaResourceNotFound.new("Domain " + domain + " is not found");
                end

		target_record = get_records(token, target_domain).find { |_|
			_["type"] == "A"
		}

                if target_record == nil
                  throw ConohaResourceNotFound.new("A Record is not found");
                end

		update_record(token, target_domain, target_record, address)
	end

	name = if params["host"]
		"#{params["host"]}.#{params["domain"]}"
	else
		params["domain"]
	end


	token = auth(params["username"], params["password"], params["tenant_id"])
	update(token, name, address)
}
