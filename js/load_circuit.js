function getDescendantProp(obj, desc)
{
	var arr = desc.split(".");
	while(arr.length && (obj = obj[arr.shift()]));
	return obj;
}

function loadCircuit(file, modules)
{
	var circuit = {};
	var circ = require(file);
	Object.keys(circ.modules).forEach(
		function(modname)
		{
			var modtype = circ.modules[modname];
			circuit[modname] = new modules[modtype](modname);
		}
	);
	circ.connections.forEach(
		function(conn)
		{
			connFrom = getDescendantProp(circuit, conn[0]);
			connTo   = getDescendantProp(circuit, conn[1]);
			connFrom.connect(connTo);
		}
	);
	return circuit;
}

module.exports.loadCircuit = loadCircuit;
