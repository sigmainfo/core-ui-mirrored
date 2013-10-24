#= require environment
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
    @

  submitHandler: (event) ->
    event.preventDefault()
    type = @model.getSelectedType()
    query = @$('input#coreon-search-query').val()
    path = if type is "all"
      Coreon.Helpers.repositoryPath("search/#{query}")
    else
      Coreon.Helpers.repositoryPath("concepts/search/#{type}/#{query}")

    Backbone.history.navigate path[1..]
    Backbone.history.loadUrl()
