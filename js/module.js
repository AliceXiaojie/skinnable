var Connection = require('./connection');

function Module(init, templates)
{
	self             = this;
	self.type        = init.type;
	self.name        = init.name;
	self.id          = init.id;
	self.cost        = init.cost;
	self.width       = init.width;
	self.height      = init.height;
	self.connections = [];

	for(side in init.connections)
		init.connections[side].forEach(
			function(c) { self.connections.push(self[c.type] = new Connection(c)); }
		);
}

module.exports = Module;
