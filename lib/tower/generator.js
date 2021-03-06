var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Tower.Generator = (function(_super) {

  __extends(Generator, _super);

  Generator.prototype.sourceRoot = __dirname;

  Generator.run = function(type, options) {
    return new Tower.Generator[Tower.Support.String.camelize(type)](options);
  };

  function Generator(options) {
    var name,
      _this = this;
    if (options == null) options = {};
    _.extend(this, options);
    if (!this.projectName) {
      name = process.cwd().split("/");
      this.projectName = name[name.length - 1];
    }
    this.destinationRoot || (this.destinationRoot = process.cwd());
    this.currentSourceDirectory = this.currentDestinationDirectory = ".";
    if (!this.project) {
      this.project = this.buildProject();
      this.user = {};
      this.buildUser(function(user) {
        _this.user = user;
        if (_this.modelName) {
          _this.model = _this.buildModel(_this.modelName, _this.project.className, _this.program.args);
        }
        return _this.run();
      });
    }
  }

  return Generator;

})(Tower.Class);

require('./generator/actions');

require('./generator/configuration');

require('./generator/resources');

require('./generator/shell');

Tower.Generator.include(Tower.Generator.Actions);

Tower.Generator.include(Tower.Generator.Configuration);

Tower.Generator.include(Tower.Generator.Resources);

Tower.Generator.include(Tower.Generator.Shell);

require('./generator/generators/tower/app/appGenerator');

require('./generator/generators/tower/model/modelGenerator');

require('./generator/generators/tower/view/viewGenerator');

require('./generator/generators/tower/controller/controllerGenerator');

require('./generator/generators/tower/helper/helperGenerator');

require('./generator/generators/tower/assets/assetsGenerator');

require('./generator/generators/tower/mailer/mailerGenerator');

require('./generator/generators/tower/scaffold/scaffoldGenerator');

module.exports = Tower.Generator;
