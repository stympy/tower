connect = require('express')
File    = require('pathfinder').File

server  = require('express').createServer()
io      = require('socket.io').listen(server)

class Tower.Application extends Tower.Class
  @use: ->
    @middleware ||= []
    @middleware.push arguments
  
  @defaultStack: ->
    @use connect.favicon(Tower.publicPath + "/favicon.ico")
    @use connect.static(Tower.publicPath, maxAge: Tower.publicCacheDuration)
    @use connect.profiler() if Tower.env != "production"
    @use connect.logger()
    @use connect.query()
    @use connect.cookieParser(Tower.cookieSecret)
    @use connect.session secret: Tower.sessionSecret
    @use connect.bodyParser()
    @use connect.csrf()
    @use connect.methodOverride("_method")
    @use Tower.Middleware.Agent
    @use Tower.Middleware.Location
    if Tower.httpCredentials
      @use connect.basicAuth(Tower.httpCredentials.username, Tower.httpCredentials.password)
    @use Tower.Middleware.Router
    @middleware

  @instance: ->
    unless @_instance
      require "#{Tower.root}/config/application"
    @_instance
  
  constructor: ->  
    throw new Error("Already initialized application") if Tower.Application._instance
    Tower.Application.middleware ||= []
    Tower.Application._instance = @
    @server ||= server
    @io     ||= io
    
  use: ->
    @constructor.use arguments...
  
  initialize: ->
    #Tower.Route.initialize()
    require "#{Tower.root}/config/application"
    
    Tower.Support.Dependencies.load "#{Tower.root}/config/locales/en", (path) ->
      Tower.Support.I18n.load path
      
    require "#{Tower.root}/config/routes"
    
    #Tower.Support.Dependencies.load "#{Tower.root}/app/models"
    #Tower.Model.initialize()
    #Tower.View.initialize()
    Tower.Support.Dependencies.load("#{Tower.root}/app/helpers")
    #Tower.Controller.initialize()
    Tower.Support.Dependencies.load("#{Tower.root}/app/controllers")
    
    # load initializers
    require "#{Tower.root}/config/environments/#{Tower.env}"
    paths = File.files("#{Tower.root}/config/initializers")
    require(path) for path in paths
    
  teardown: ->
    #Tower.Route.teardown()
    Tower.Route.clear()
    delete require.cache[require.resolve("#{Tower.root}/config/locales/en")]
    delete require.cache[require.resolve("#{Tower.root}/config/routes")]
    delete Tower.Route._store
    #Tower.Model.teardown()
    # Tower.Support.Dependencies.load("#{Tower.root}/app/models")
    # delete @_store
    #Tower.View.teardown()
    #Tower.Controller.teardown()
    delete Tower.Controller._helpers
    delete Tower.Controller._layout
    delete Tower.Controller._theme
  
  stack: ->
    middlewares = @constructor.middleware
    
    unless middlewares && middlewares.length > 0
      middlewares = @constructor.defaultStack()
      
    for middleware in middlewares
      args        = Tower.Support.Array.args(middleware)
      if typeof args[0] == "string"
        middleware  = args.shift()
        @server.use connect[middleware].apply(connect, args) 
      else
        @server.use args...
    
    @
    
  listen: ->
    unless Tower.env == "test"
      @server.listen(Tower.port)
      _console.info("Tower #{Tower.env} server listening on port #{Tower.port}")
  
  run: ->
    @initialize()
    @stack()
    @listen()

module.exports = Tower.Application