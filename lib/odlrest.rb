class Odlrest

  if Rails.env.development?
    @odl_server = '10.0.2.2'
  elsif Rails.env.production?
    @odl_server = '172.31.37.109'

  def self.getnodes
    base_url = "http://admin:admin@#{@odl_server}:8181/restconf/operational//network-topology:network-topology/topology/flow:1/"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    return data_parsed["topology"]["node"]
  end

  def self.gettopo
    base_url = "http://admin:admin@#{@odl_server}:8181/restconf/operational/network-topology:network-topology/"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    return data_parsed["network_topology"]["topology"][0]
  end

end

