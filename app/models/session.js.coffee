#= require environment
#= require models/repository

repository = null

class Coreon.Models.Session extends Backbone.Model
  
  @auth_root = null

  @load = () ->
    request = $.Deferred()
    if token = localStorage.getItem "coreon-session"
      session = new @ auth_token: token
      session.fetch()
        .done( -> request.resolve session )
        .fail( -> request.resolve null )
    else
      request.resolve null
    request.promise()

  @authenticate = (email, password) ->
    request = $.Deferred()
    session = new @
    session.save({}, data: $.param email: email, password: password)
      .done( -> request.resolve session )
      .fail( -> request.resolve null )
    request.promise()

  defaults: ->
    repositories: []
    current_repository_id: null

  idAttribute: "auth_token"

  urlRoot: -> "#{Coreon.Models.Session.auth_root.replace /\/$/, ''}/login"

  currentRepository: ->
    if currentId = @get "current_repository_id"
      attrs = repo for repo in @get "repositories" when repo.id is currentId
    attrs ?= @get("repositories")[0]
    if attrs?
      unless attrs.id is repository?.id
        repository = new Coreon.Models.Repository attrs 
    else
      repository = null
    repository

  destroy: ->
    super
    localStorage.removeItem "coreon-session"
