//Directions
var IN  = "in";
var OUT = "out";

function Connection(name, direction)
{
	this.name = name;
	this.direction = direction;
	this.connectedTo = null;
}

Connection.prototype.connect(destination)
{
	this.connectedTo = destination;
	destination.connectedTo = this;
}
