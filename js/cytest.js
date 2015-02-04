var _ = require('lodash');
var cytoscape = require('cytoscape');
var modules = require('./modules');
var therm = require('./thermostat');
var jf = require('jsonfile');

var cy = cytoscape();

var cydata = {}
var mods = {}

Object.keys(modules).forEach(
	function(modname)
	{
		if(modname[0] == '_')
			return;

		var props;

		if(modules[modname].hasOwnProperty('template'))
			props = _.assign(modules[modules[modname].template], modules[modname]);
		else
			props = modules[modname];

		mods[modname] = props;
	}
);


//Add modules and their possible connections
Object.keys(therm.modules).forEach(
	function(modname)
	{
		//Add each module
		props = mods[therm.modules[modname]];
		cy.add(
		{
			group: 'nodes',
			data:
			{
				id: modname,
				type: props.type
			}
		});

		//Add the connectable parts of the module as sub-nodes
		for(var side in props.connections)
			props.connections[side].forEach(
				function(c)
				{
					cy.add(
					{
						group: 'nodes',
						data:
						{
							id: modname + '.' + c.type,
							parent: modname
						}
					});
				}
			);
	}
);


//Connect modules together now that all are in the graph
therm.connections.forEach(
	function(conn)
	{
		var from = conn[0];
		var to   = conn[1];
		cy.add(
		{
			group: 'edges',
			data:
			{
				id: from + '-' + to,
				source: from,
				target: to
			}
		});
	}
);

jf.writeFileSync('thermostat-cy.json', cy.json());
