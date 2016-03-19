class Odlrest

  def self.getnodes
    base_url = "http://admin:admin@odl:8181/restconf/operational/opendaylight-inventory:nodes/"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    return data_parsed["nodes"]["node"]
  end

  def self.gettopo
    base_url = "http://admin:admin@odl:8181/restconf/operational/network-topology:network-topology/"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    return data_parsed["network_topology"]["topology"]
  end

end

