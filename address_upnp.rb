require "rubygems"
require "UPnP"

address(:upnp) { |params|
	upnp = UPnP::UPnP.new
	upnp.externalIP
} 
