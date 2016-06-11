class OdlController < ApplicationController
  
  respond_to :html, :js

  def index
  	@nodes = Odlrest.getnodes
  	@topo_nodes = Buildtopo.nodes
  	@topo_links = Buildtopo.links
  end

  def positions
  	@positions = params[:positions]
  	@positions.each do |position|
  		name = position[0]
  		x = position[1][0]
  		y = position[1][1]
  		topology = Topology.where(name:name).first_or_initialize
  		topology.x = x
  		topology.y = y
  		topology.save
  	end
  	respond_with(@positions) do |format|
      format.html {render :partial => "positions" }
    end
  end

end
