#= require environment
#= require modules/helpers
#= require modules/core_api

class Coreon.Models.Search extends Backbone.Model

  Coreon.Modules.include @, Coreon.Modules.CoreAPI

  defaults:
    hits: []

  url: ->
    "/#{@get 'path'}"

  params: ->
    params = "search[query]": @get "query"
    if @has "target"
      params["search[only]"] = switch @get "target"
        when "terms" then "terms"
        else "properties/#{@get "target"}"
    params["search[tolerance]"] = 2
    params

  query: ->
    path = encodeURIComponent @get("query")
    path = @get("target") + "/" + path if @has "target"
    path

  fetch: (options = {}) ->
    options.method ?= "POST"
    options.data ?= @params()
    super options
