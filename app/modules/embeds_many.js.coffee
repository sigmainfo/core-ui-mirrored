#= require environment

createRelation = (model, attr) ->
  relation = model._relations[attr]
  options = {}
  options.model = relation.model if relation.model?
  collection = new relation.collection model.get(attr), options
  model.on "change:#{attr}", -> collection.set model.get attr
  collection.on "all", -> model.set attr, collection.toJSON(), silent: true
  collection

Coreon.Modules.EmbedsMany =
  
  embedsMany: (attr, options = {}) ->
    
    (@::_relations ?= {})[attr] =
      collection: options.collection or Backbone.Collection
      model: options.model or null

    @::[attr] = ->
      @["_#{attr}"] ?= createRelation @, attr
