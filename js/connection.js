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

module.exports = Connection;
