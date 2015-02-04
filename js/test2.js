var mLoader = require('./load_modules');
var cLoader = require('./load_circuit');
var modules = mLoader.loadModules('./modules');
var circuit = cLoader.loadCircuit('./thermostat', modules);
console.log(circuit);
