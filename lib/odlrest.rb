class Odlrest

  if Rails.env.development?
    #@odl_server = '10.0.2.2'
    @odl_server = 'ec2-54-213-196-58.us-west-2.compute.amazonaws.com'
  elsif Rails.env.production?
    @odl_server = '172.31.37.109'
  end

  def self.getnodes
    base_url = "http://admin:admin@#{@odl_server}:8181/restconf/operational/network-topology:network-topology/topology/flow:1/"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    return data_parsed["topology"]["node"]
  end

  def self.gettopo
    base_url = "http://admin:admin@#{@odl_server}:8181/restconf/operational/network-topology:network-topology"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    if Rails.env.development?
      return data_parsed["network_topology"]["topology"][2]
    elsif Rails.env.production?
      return data_parsed["network_topology"]["topology"][2]
    end
  end

  def self.getsingletopo(node_id)
    base_url = "http://admin:admin@#{@odl_server}:8181/restconf/operational/network-topology:network-topology/topology/flow:1/node/#{node_id}"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    return data_parsed
  end

  def self.gethostgw(node_id)
    firsthop_gw = getsingletopo(node_id)["node"]["attachment_points"]["tp_id"]
    hop = [firsthop_gw[0..firsthop_gw.rindex(':')-1],firsthop_gw]
    return hop
  end

  def self.getflows_t0(node_id)
    base_url = "http://admin:admin@#{@odl_server}:8181/restconf/operational/opendaylight-inventory:nodes/node/#{node_id}/table/0"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    return data_parsed["table"]["flow"]
  end

  def self.getflow_t0(node_id,flow_id)
    base_url = "http://admin:admin@#{@odl_server}:8181/restconf/operational/opendaylight-inventory:nodes/node/#{node_id}/table/0/flow/#{URI.encode(flow_id)}"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :"Content-Type" => 'application/xml')
    data_parsed = Hash.from_xml(data)
    return data_parsed["flow"]
  end

  def self.endpoint(node_id,port_id)
    Odlrest.gettopo["link"].each do |link|
      if link["source"]["source_tp"] == "#{node_id}:#{port_id}"
        return [link["destination"]["dest_node"],link["destination"]["dest_tp"]]
      end
    end
  end

  def self.getaddresses(host_id)
    return getsingletopo(host_id)["node"]["addresses"]
  end

  def self.getnext(node_id,in_port,dst_host)
    flows = {}
    dest_mac = Odlrest.getaddresses(dst_host)["mac"]
    dest_ip = Odlrest.getaddresses(dst_host)["ip"]
    Odlrest.getflows_t0(node_id).map do |flow|
      if flow["match"]
        if ((flow["match"]["in_port"] && flow["match"]["in_port"] == in_port) || 
            (flow["match"]["ipv4_destination"] && flow["match"]["ipv4_destination"] == dest_ip) ||
            (flow["ethernet_match"] && flow["ethernet_match"]["ethernet_destination"] && flow["ethernet_match"]["ethernet_destination"]["address"] == dest_mac)
            ) 
          flows[flow["id"]] = flow["priority"].to_i
        end
      end
    end
    the_flow = flows.max_by{|k,v| v}
    out_port = []
    endpoints = []
    if Odlrest.getflow_t0(node_id,the_flow[0])["instructions"]["instruction"]["apply_actions"]["action"].class == Array
      Odlrest.getflow_t0(node_id,the_flow[0])["instructions"]["instruction"]["apply_actions"]["action"].map do |action|
        unless action["output_action"]["output_node_connector"] == "CONTROLLER"
          out_port << action["output_action"]["output_node_connector"]
        end
      end
    else 
      out_port = Odlrest.getflow_t0(node_id,the_flow[0])["instructions"]["instruction"]["apply_actions"]["action"]["output_action"]["output_node_connector"]
    end
    # Got out_port
    if out_port.length == 1
      unless out_port == in_port.delete(in_port[0..in_port.rindex(':')])
        endpoints << Odlrest.endpoint(node_id,out_port[0])
      end
    else
      out_port.each do |port|
        unless port == in_port.delete(in_port[0..in_port.rindex(':')]) # split horizon
          endpoints << Odlrest.endpoint(node_id,port)
        end
      end 
    end
    to_delete = []
    endpoints.each do |element|
      if ((element[0].include? "host") && (element[0] != "host:"+dest_mac))
        # marking not matching hosts as deletable from path
        to_delete << element
      end
    end
    # deleting not matching hosts at the end of the path
    to_delete.map do |badhost|
      endpoints.delete(badhost)
    end
    return endpoints
  end

  def self.getpaths(src_host,dst_host)
    #define first hop
    hop = Odlrest.gethostgw(src_host)
    hops = []
    hops << hop[0]
    while true do
      nexthop = Odlrest.getnext(hop[0],hop[1],dst_host)
      if nexthop[0]
        if nexthop[0][0].include? dst_host
          break
        else
          hops << nexthop[0][0]
          hop = nexthop[0]
        end      
      else
        break
      end
    end
    return hops
  end

end

