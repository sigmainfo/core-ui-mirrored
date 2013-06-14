#= require environment
#= require collections/notifications
#= require models/ability
#= require modules/core_api

class Coreon.Models.CoreonSession extends Backbone.Model
  defaults:
    emails:       []
    user_name:    no
    state:        "pending"  # TODO: sane default?
    repositories: []
    ttl:          3600       # TODO: sane default?
    auth_root:    "/api/auth/"
    repo_root:    no

  valid: ->
    @getToken()?

  initialize: ->
    @created_at = Date.now()
    @ability = new Coreon.Models.Ability
    @notifications = new Coreon.Collections.Notifications


  @activate: (email, password) ->
    @_fetch_via_login(email, password)


  reactivate: (password) ->
    @_fetch_via_user_id(password)


  refresh: ->
    @_fetch_via_token()


  deactivate: ->
    @unsetToken()


  @_fetch_via_login: (email, password) ->
    options =
      url: @get("auth_root") + "login"
      type: "POST"
      dataType: "json"
      data:
        email: email
        password: password
    $.ajax(options).done @onFetch


  _fetch_via_user_id: (password) ->
    options =
      url: @get("auth_root") + "login"
      type: "POST"
      dataType: "json"
      data:
        user_id: @get("user_id")
        password: password
    $.ajax(options).done @onFetch


  _fetch_via_token: ->
    token = @getToken()
    options =
      url: @get("auth_root") + "login/" + @getToken()
      type: "GET"
    if token?
      $.ajax(options).done @onFetch
      return @
    else
      return null


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
    localStorage.removeItem "session"
    localStorage.removeItem "updated_at"
    @set(k, v) for k,v of @defaults
    @message I18n.t("notifications.account.logout")
    @trigger "change:token"

    $.ajax
      url: @get("auth_root") + "login/" + @getToken()
      type: "DELETE"


  getToken: ->
    #t = localStorage.getItem "updated_at"
    #return null if Date.now() - t < @ttl()*1000
    localStorage.getItem "session"


  onFetch: (data)=>
    @setToken(data.auth_token)
    @save
      user_id:      data.user.id
      user_state:   data.user.state
      user_name:    data.user.name
      emails:       data.user.emails
      repositories: data.repositories
      ttl:          data.ttl

    @message I18n.t("notifications.account.login", name: @get "user_name")
    @setRepository(data.repositories[0]) if data.repositories.length > 0


  setRepository: (repo)->
    uri = repo.graph_uri
    if repo.user_roles? and "maintainer" in repo.user_roles
      role = "maintainer"
    else if repo.user_roles? and "user" in repo.user_roles
      role = "user"
    else
      role = false

    @set "repo_root", uri
    @ability.set "role", role


  sync: (action, model, options)->
    switch action
      when "create"
        @_fetch_via_login(options.email, options.password)
      when "update"
        @_fetch_via_user_id(options.password)
      when "read"
        @_fetch_via_token()
      when "delete"
        @unsetToken()

