var _      = require('lodash');

function Connection(init)
{
	this.name        = init.name || init.type;
	this.direction   = init.direction;  //"in" or "out"
	this.position    = init.position || 0;
	this.connectedTo = null;
}

Connection.prototype.connect = function(destination)
{
	this.connectedTo        = destination;
	destination.connectedTo = this;
}

function Module(init)
{
	self             = this;
	self.type        = init.type;
	self.name        = init.name   || init.type;
	self.id          = init.id     || 'unknown';
	self.cost        = init.cost   || 0;
	self.width       = init.width  || -1;
	self.height      = init.height || -1;
	self.connections = [];

	for(var side in init.connections)
		init.connections[side].forEach(function(c){
			self.connections.push(self[c.type] = new Connection(c));
		});
}


function loadModules(file)
{
	var mods = require(file);
	var modules = {};
	Object.keys(mods).forEach(
		function(modname)
		{
			//Ignore template modules
			if(modname[0] == '_')
				return;

			var props;

			//Get properties from template if there
			if(mods[modname].hasOwnProperty('template'))
				props = _.assign(mods[mods[modname].template], mods[modname]);
			else
				props = mods[modname];

			//Set up the new object
			modules[modname] = function(name)
			{
				Module.call(this, props);
				this.name = name;
			}
			modules[modname].prototype = Object.create(Module.prototype);
		}
	);
	return modules;
}

module.exports.loadModules = loadModules;
