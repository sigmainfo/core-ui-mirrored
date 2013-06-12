#= require environment
#= require collections/connections
#= require models/ability
#= require modules/core_api

class Coreon.Models.CoreonSession extends Backbone.Model
  defaults:
    emails:       []
    user_name:    ""
    state:        "pending"  # TODO: sane default?
    repositories: []
    ttl:          3600       # TODO: sane default?
    auth_root:    "/api/auth/"

  valid: ->
    @getToken()?

  initialize: ->
    @created_at = Date.now()

    @ability = new Coreon.Models.Ability
    @connections = new Coreon.Collections.Connections
    @connections.session = @


  activate: (email, password) ->
    @_fetch_via_login(email, password)


  reactivate: (password) ->
    @_fetch_via_user_id(password)


  refresh: ->
    @_fetch_via_token()


  deactivate: ->
    @unsetToken()


  _fetch_via_login: (email, password) ->
    options =
      url: @get("auth_root") + "login"
      type: "POST"
      dataType: "json"
      data:
        email: email
        password: password

    @connections.add
      model: @
      options: options
      xhr: $.ajax(options).done @onFetch


  _fetch_via_user_id: (password) ->
    options =
      url: @get("auth_root") + "login"
      type: "POST"
      dataType: "json"
      data:
        user_id: @get("user_id")
        password: password

    @connections.add
      model: @
      options: options
      xhr: $.ajax(options).done @onFetch


  _fetch_via_token: ->
    options =
      url: @get("auth_root") + "login/" + @getToken()
      type: "GET"

    @connections.add
      model: @
      options: options
      xhr: $.ajax(options).done @onFetch


  update_repository_ids: ->
    @repositories_by_id = {}
    @repositories_by_id[repo.id] = repo for repo in @get("repositories")


  set_repository_root: (repository_id)->
    @set "repository_root", @repositories_by_id[repository_id].graph_uri


  ttl: ->
    @get("ttl")


  setToken: (token)->
    @trigger "change:token"
    localStorage.setItem "session", token
    localStorage.setItem "updated_at", Date.now()


  unsetToken: ->
    @trigger "change:token"
    localStorage.removeItem "session"
    localStorage.removeItem "updated_at"

    options =
      url: @get("auth_root") + "login/" + @getToken()
      type: "DELETE"

    @connections.add
      model: @
      options: options
      xhr: $.ajax(options)


  getToken: ->
    #t = localStorage.getItem "updated_at"
    #return null if Date.now() - t < @ttl()*1000
    localStorage.getItem "session"


  onFetch: (data) =>
    @setToken(data.auth_token)
    @save
      user_id:      data.user.id
      user_state:   data.user.state
      user_name:    data.user.name
      emails:       data.user.emails
      repositories: data.repositories
      ttl:          data.ttl


  sync: (action, model, options)->
    switch action
      when "create"
        @_fetch_via_login(options.email, options.password)
      when "update"
        @_fetch_via_user_id(options.password)
      when "read"
        @_fetch_via_token()
      when "delete"
        @connections.destroy()
        @unsetToken()
        @set(k, v) for k,v of @defaults

