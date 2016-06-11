class Buildtopo

  def self.nodes
    @topo = Odlrest.gettopo
    @nodes = {}
    @nodes_topo = []
    @node_id = 0
    if @topo["node"]
        @topo["node"].map do |node|
            node_item = {}
            node_item["id"] = @node_id
            node_item["name"] = node["node_id"]
            topology_saved = Topology.find_by(name:node_item["name"])
            if topology_saved
              node_item["x"] = topology_saved.x
              node_item["y"] = topology_saved.y      
            else
              node_item["x"] = 150*@node_id.to_i
              node_item["y"] = 50*@node_id.to_i
            end
            @nodes[node["node_id"]] = node_item
            @nodes_topo << node_item
            @node_id += 1
        end
        return @nodes_topo.to_json
    else
        return [{"id"=>0, "name"=>"no-network-detected", "x"=>0, "y"=>0}].to_json
    end
  end

  def self.links
    @topo = Odlrest.gettopo
    @links = []
    if @topo["link"]
        @topo["link"].map do |link|
            link_item = {}
            link_item["source"] = [@nodes[link["source"]["source_node"]]["id"].to_i,@nodes[link["destination"]["dest_node"]]["id"].to_i].min
            link_item["target"] = [@nodes[link["destination"]["dest_node"]]["id"].to_i,@nodes[link["source"]["source_node"]]["id"].to_i].max
            unless @links.include? link_item
                @links << link_item
            end
        end
        return @links.to_json
    else 
        @links = [0]
    end
  end

end

