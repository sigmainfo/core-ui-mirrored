#= require environment
#= require modules/prompt
#= require lib/coreon_select
#= require jquery.ui.position
#= require templates/widgets/languages
#= require helpers/repository_path

class Coreon.Views.Widgets.LanguagesView extends Backbone.View

  id: "coreon-languages"
  className: "widget blue-widget"
    
  template: Coreon.Templates["widgets/languages"]

  events:
    "submit form#coreon-languages-form"  : "submitHandler"

  initialize: ->
    #@listenTo @model, "change:selectedTypeIndex", @onChangeSelectedType
    #@select = null

  render: ->
    @$el.html @template()
    
    @$('select').coreonSelect()
    
    @

  submitHandler: (event) ->
    event.preventDefault()
    