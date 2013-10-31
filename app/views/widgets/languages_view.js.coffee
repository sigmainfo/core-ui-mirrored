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
    "change select[name=source_language]"  : "onChangeSourceLanguage"

  initialize: ->

  render: ->
    @$el.html @template()
    
    @$('select[name=source_language]').val(Coreon.application?.repositorySettings 'sourceLanguage')
    @$('select').coreonSelect()
    
    @

  onChangeSourceLanguage: (e) ->
    Coreon.application?.repositorySettings 'sourceLanguage', $(e.target).val()
    

    