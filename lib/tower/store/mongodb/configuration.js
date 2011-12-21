
  Tower.Store.MongoDB.Configuration = {
    ClassMethods: {
      config: {
        development: {
          name: "metro-development",
          port: 27017,
          host: "127.0.0.1"
        },
        test: {
          name: "metro-test",
          port: 27017,
          host: "127.0.0.1"
        },
        staging: {
          name: "metro-staging",
          port: 27017,
          host: "127.0.0.1"
        },
        production: {
          name: "metro-production",
          port: 27017,
          host: "127.0.0.1"
        }
      },
      configure: function(options) {
        return Tower.Support.Object.mixin(this.config, options);
      },
      env: function() {
        return this.config[Tower.env];
      },
      lib: function() {
        return this._lib || (this._lib = require('mongodb'));
      }
    }
  };

  module.exports = Tower.Store.MongoDB.Configuration;