#= require environment

class Coreon.Models.ConceptMapNode extends Backbone.Model

  defaults: ->
    model: null
    type: null
    parent_node_ids: []
    child_node_ids: []
    loaded: yes
    expanded: no
    hit: no
    parent_of_hit: no

  initialize: ->
    @stopListening()

    if model = @get "model"
      @set {
        id: model.id
        type: model.constructor.name.toLowerCase()
        hit: model.has "hit"
      }, silent: yes
      @update model, silent: yes
      @listenTo model, "change nonblank", @update

  update: (model, options) ->
    attrs =
      label: model.get("label") or model.get("name")
      loaded: not model.blank
    if model.has "superconcept_ids"
      attrs.parent_node_ids = model.get "superconcept_ids"
    if model.has "subconcept_ids"
      attrs.child_node_ids = model.get "subconcept_ids"
    @set attrs, options

  path: ->
    if model = @get "model"
      model.path()
    else
      "javascript:void(0)"

  toJSON: ->
    json = super
    delete json.model
    delete json.parent_node_ids
    delete json.child_node_ids
    json
