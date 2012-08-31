#= require environment

class Coreon.Models.SearchType extends Backbone.Model

  defaults:
    availableTypes: ["all", "definition", "terms"]
    selectedTypeIndex: 0

  getSelectedType: ->
    @get("availableTypes")[@get "selectedTypeIndex"]
