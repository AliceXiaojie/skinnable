var loader = require('./load_modules');
var modules = loader.loadModules('./modules');

A1 = new modules.Arduino('Arduino');
B1 = new modules.Button('Button');

B1.in.connect(A1.D5);

console.log(A1);
console.log(B1);
