#= require environment
#= require views/composite_view
#= require templates/widgets/search_target_select
#= require views/widgets/search_target_select_dropdown_view

class Coreon.Views.Widgets.SearchTargetSelectView extends Coreon.Views.CompositeView

  id: "coreon-search-target-select"

  template: Coreon.Templates["widgets/search_target_select"]

  events:
    "click .toggle": "showDropdown"
    "click .hint": "onFocus"

  initialize: ->
    super
    @model.on "change", @render, @
    @dropdown = new Coreon.Views.Widgets.SearchTargetSelectDropdownView model: @model 

  render: ->
    @$el.html @template selectedType: @model.getSelectedType() 
    @

  delegateEvents: ->
    super
    @dropdown.delegateEvents()

  undelegateEvents: ->
    super
    @dropdown.undelegateEvents()

  showDropdown: (event) ->
    @dropdown.delegateEvents()
    $("#coreon-modal").append @dropdown.render().$el

  hideHint: ->
    @$(".hint").hide()

  revealHint: ->
    @$(".hint").show()

  onFocus: (event) ->
    @hideHint() 
    @trigger "focus"
