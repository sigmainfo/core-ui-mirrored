#= require environment
#= require models/repository
#= require models/concept
#= require models/ability
#= require collections/clips
#= require collections/hits

repository = null

class Coreon.Models.Session extends Backbone.Model

  @authRoot = null

  @load = ->
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

  urlRoot: -> "#{Coreon.Models.Session.authRoot.replace /\/$/, ''}/login"

  initialize: ->
    @off()
    @on "change:auth_token", @onChangeToken, @
    @on "change:current_repository_id", @updateRepository, @

  reauthenticate: (password) ->
    @unset "auth_token"
    @save {},
      data:
        $.param
          password: password
          user_id: @get("user").id
    @

  set: (key, value, options) ->
    if typeof key is "object"
      [attrs, options] = arguments
    else
      (attrs = {})[key] = value
    changed = no
    if attrs.hasOwnProperty "repositories"
      repositories = attrs.repositories
      changed = yes
    else
      repositories = @get "repositories"
    if attrs.hasOwnProperty "current_repository_id"
      current_repository_id = attrs.current_repository_id
      changed = yes
    else
      current_repository_id = @get "current_repository_id"
    if changed
      if repositories?.length > 0
        available = no
        for repo in repositories when repo.id is current_repository_id
          available = yes
          break
        unless available
          attrs.current_repository_id = repositories[0].id
      else
        attrs.current_repository_id = null
    super attrs, options

  currentRepository: ->
    current_repository_id = @get "current_repository_id"
    if current_repository_id
      repositories = @get "repositories"
      for repo in repositories when repo.id is current_repository_id
        attrs = repo
        break
      if not repository? or attrs.id isnt repository.id
        repository = new Coreon.Models.Repository attrs
    else
      repository = null
    repository

  ability: ->
    @_ability ?= new Coreon.Models.Ability @

  onChangeToken: (model, token) ->
    @_ability = null
    if token
      localStorage.setItem "coreon-session", token
    else
      localStorage.removeItem "coreon-session"

  updateRepository: ->
    Coreon.Models.Concept.collection().reset []
    Coreon.Collections.Clips.collection().reset []
    Coreon.Collections.Hits.collection().reset []
    @set 'repository', @currentRepository()

  destroy: (options) ->
    localStorage.removeItem "coreon-session"
    super
