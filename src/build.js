var fs   = require('fs');
var jade = require('jade');

// Compile the template to a function string
var jsFunctionString = jade.compileFileClient('jade/index.jade', {name: "fancyTemplateFun"});

// Maybe you want to compile all of your templates to a templates.js file and serve it to the client
fs.writeFileSync("templates.js", jsFunctionString);