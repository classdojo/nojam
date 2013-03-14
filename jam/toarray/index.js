define([], function(require) {

    var __dirname = "toarray",
    __filename    = "toarray/index.js",
    module        = { exports: {} },
    exports       = module.exports;

    module.exports = function(item) {
  if(item === undefined)  return [];
  return item instanceof Array ? item : [item];
}

    return module;
});