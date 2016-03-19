class Buildtopo

  @topo = Odlrest.gettopo

  def self.nodes
    @nodes = []
    @topo["node"].map do |node|
        node_item = {}
        node_item["id"] = node["node_id"].split(':')[-1].to_i
        node_item["name"] = node["node_id"]
        node_item["x"] = 150*node_item["id"].to_i
        node_item["y"] = 50*node_item["id"].to_i
        @nodes << node_item
    end
    return @nodes.sort_by { |k, v| k["id"] }.to_json
  end

  def self.links
    @links = []
    @topo["link"].map do |link|
        link_item = {}
        link_item["source"] = [link["source"]["source_node"].split(':')[-1].to_i,link["destination"]["dest_node"].split(':')[-1].to_i].min - 1
        link_item["target"] = [link["source"]["source_node"].split(':')[-1].to_i,link["destination"]["dest_node"].split(':')[-1].to_i].max - 1
        unless @links.include? link_item
            @links << link_item
        end
    end
    return @links.sort_by { |k, v| k["source"] }.to_json
  end

end