var Module = require('./module');
var mods   = require('./modules');
var _      = require('lodash');

modules = {}
for(var modname in mods)
{
	if(modname[0] == '_')
		continue;
	if(mods[modname].hasOwnProperty('prototype'))
		modules[modname] = new Module(
			_.assign(mods[mods[modname].prototype], mods[modname]));
	else
		modules[modname] = new Module(mods[modname]);
}

console.log(modules);
