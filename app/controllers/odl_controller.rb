class OdlController < ApplicationController
  def index
  	@nodes = Odlrest.getnodes
  	@topo_nodes = Buildtopo.nodes
  	@topo_links = Buildtopo.links
  end
end
