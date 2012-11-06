#= require environment
#= require views/composite_view
#= require templates/widgets/search_target_select
#= require views/widgets/search_target_select_dropdown_view

class Coreon.Views.Widgets.SearchTargetSelectView extends Coreon.Views.CompositeView

  id: "coreon-search-target-select"

  template: Coreon.Templates["widgets/search_target_select"]

  events:
    "click .toggle" : "showDropdown"
    "click .hint"   : "onFocus"

  initialize: ->
    super
    @model.on "change", @render, @
    @dropdown = new Coreon.Views.Widgets.SearchTargetSelectDropdownView model: @model
    @add @dropdown

  render: ->
    @$el.html @template selectedType: @model.getSelectedType() 
    super

  showDropdown: (event) ->
    $("#coreon-modal").append @dropdown.render().$el
    @dropdown.delegateEvents()

  hideHint: ->
    @$(".hint").hide()

  revealHint: ->
    @$(".hint").show()

  onFocus: (event) ->
    @hideHint() 
    @trigger "focus"
