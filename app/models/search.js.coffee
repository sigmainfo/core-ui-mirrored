#= require environment

class Coreon.Models.Search extends Backbone.Model

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


  sync: (method, model, options = {}) ->
    _(options).extend
      type: "POST"
      data: @params()
    Coreon.application.sync method, model, options
