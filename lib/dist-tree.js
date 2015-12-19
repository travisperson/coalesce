
var bundle = require('./bundle'),
    mergeTrees = require('broccoli-merge-trees');
    
var src = require('path').join(__dirname, '..','src');

module.exports = mergeTrees([
  require('./bower'),
  bundle(src, {modules: 'system', optimize: false}),
  bundle(src, {modules: 'system', optimize: true}),
  bundle(src, {modules: 'amd', optimize: false}),
  bundle(src, {modules: 'amd', optimize: true})
]);