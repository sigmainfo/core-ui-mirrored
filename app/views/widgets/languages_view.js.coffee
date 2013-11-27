#= require environment
#= require modules/prompt
#= require lib/select
#= require templates/widgets/languages
#= require helpers/repository_path

class Coreon.Views.Widgets.LanguagesView extends Backbone.View

  id: "coreon-languages"
  className: "widget blue-widget"

  template: Coreon.Templates["widgets/languages"]

  events:
    "change select[name=source_language]"  : "onChangeSourceLanguage"
    "change select[name=target_language]"  : "onChangeTargetLanguage"

  initialize: ->
    Coreon.application?.repository()?.on 'remoteSettingChange', =>
      @render()

  render: ->
    @$el.html @template()

    @$('select[name=source_language]').val(Coreon.application?.repositorySettings 'sourceLanguage')
    @$('select[name=target_language]').val(Coreon.application?.repositorySettings 'targetLanguage')
    @$('select').coreonSelect()

    @

  onChangeSourceLanguage: (e) ->
    Coreon.application?.repositorySettings 'sourceLanguage', $(e.target).val()

  onChangeTargetLanguage: (e) ->
    Coreon.application?.repositorySettings 'targetLanguage', $(e.target).val()
