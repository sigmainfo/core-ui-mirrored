#= require environment
#= require models/concept
#= require models/repository

class Coreon.Models.ConceptMapNode extends Backbone.Model

  defaults: ->
    model: null
    type: null
    parent_node_ids: []
    child_node_ids: []
    loaded: yes
    hit: no
    score: 0
    parent_of_hit: no
    busy: false
    rendered: false

  detectType = (model) ->
    switch
      when model instanceof Coreon.Models.Concept
        'concept'
      when model instanceof Coreon.Models.Repository
        'repository'
      else
        null

  initialize: ->
    @stopListening()
    if model = @get "model"
      score = 0
      if hit = model.get 'hit'
        score = hit.get 'score'
      @set {
        id: model.id
        type: detectType model
        hit: hit?
        score: score
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
    json.path = @path()
    json
