#= require environment

class Coreon.Models.ConceptMapNode extends Backbone.Model
  
  defaults: ->
    model: null
    type: null
    child_node_ids: []
    expanded: false
    hit: false
    parent_of_hit: false

  initialize: ->
    @stopListening()

    if model = @get "model"
      @set {
        id: model.id
        type: model.constructor.name.toLowerCase()
        hit: model.has "hit"
      }, silent: yes
      @update model, silent: yes
      @listenTo model, "change", @update

  update: (model, options) ->
    label = model.get("label") or model.get("name")
    @set "label", label, options

  path: ->
    if model = @get "model"
      model.path()
    else
      "javascript:void(0)"
