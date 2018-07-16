require "net/http"

address(:inet_ip_info) { |params|
	Net::HTTP.get(URI.parse("http://inet-ip.info/ip"))
} 
