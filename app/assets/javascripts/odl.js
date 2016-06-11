$(document).ready(function(){

(function (nx) {
    /**
     * define application
     */
    var Shell = nx.define(nx.ui.Application, {
        properties: {
        },

        methods: {
            start: function () {
                //your application main entry

                // initialize a topology
                topo = new nx.graphic.Topology({
                    // set the topology view's with and height
                    width: 700,
                    height: 250,
                    // node config
                    nodeConfig: {
                        // label display name from of node's model, could change to 'model.id' to show id
                        label: 'model.name',
                        iconType: function(vertex) {  
                                var id = vertex.get("name");  
                                if (id.includes('openflow')) {
                                    return 'switch'
                                } else if (id.includes('host')) {
                                    return 'host'
                                } else {  
                                    return 'router'  
                                }  
                            }  
                    },
                    // link config
                    linkConfig: {
                        // multiple link type is curve, could change to 'parallel' to use parallel link
                        linkType: 'curve'
                    },
                    // show node's icon, could change to false to show dot
                    showIcon: true
                });

                topo.on('topologyGenerated', function(sender, event) {  
                  sender.registerScene('ce', 'CustomScene');  
                  sender.activateScene('ce');  
                });
                //set data to topology
                topo.data(topologyData);
                //attach topology to document
                var app = new nx.ui.Application();
                app.container(document.getElementById('topology'));
                topo.attach(app);
            }
        }
    });


    /**
     * create application instance
     */
    var shell = new Shell();

    /**
     * invoke start method
     */
    shell.start();
})(nx);


  $(".save_positions").click(function() {
  	
		toponodes = topo.getData().nodes;
		positions = {};

		$.each(toponodes, function( key, value ) {
 		 positions[value.name]=[value.x,value.y]
		});

	  $.ajax(
	  {data: { positions: positions }, type: 'post', url: "/positions",
	  success: function(r) { 
	  $('.positions').html(r);
	  } 
	  });


  });



});