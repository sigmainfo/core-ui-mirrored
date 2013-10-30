#= require environment

class Coreon.Models.RepositoryCache extends Backbone.Model

  url: ->
    false      

  sync: (method, model, options) ->
    switch method
      when 'read'
        rawCache = localStorage.getItem options   
        jsonCache = JSON.parse rawCache
        model.set jsonCache 
        model.id = options
      when 'delete'
        localStorage.removeItem model.id unless model.isNew()
      when 'create', 'update', 'patch'
        localStorage.setItem model.id, JSON.stringify model.toJSON()
        
