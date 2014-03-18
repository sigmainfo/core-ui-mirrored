#= require environment
#= require modules/prompt
#= require lib/select
#= require templates/widgets/languages
#= require templates/widgets/languages/select
#= require helpers/titlebar
#= require helpers/repository_path

class Coreon.Views.Widgets.LanguagesView extends Backbone.View

  id: 'coreon-languages'

  className: 'widget blue-widget'

  template: Coreon.Templates['widgets/languages']

  events:
    'change select[name=source_language]': 'updateSource'
    'change select[name=target_language]': 'updateTarget'

  initialize: (options = {}) ->
    @app = options.app or Coreon.application

    @stopListening()
    @listenTo @app
            , 'change:langs change:repository change:repositorySettings'
            , @render

  render: ->
    langs = @app.langs(ignoreSelection: on).map (id) ->
      labelComponents = [id.toUpperCase()]
      if translation = I18n.t("languages.#{id}", defaultValue: '')
        labelComponents.push translation

      id: id
      label: labelComponents.join ' '

    @$el.html @template
      select: Coreon.Templates['widgets/languages/select']
      langs: langs
      source: @app.sourceLang()
      target: @app.targetLang()

    @$('select').coreonSelect()
    @

  updateSource: (event) ->
    value = $(event.target).val() or null
    @app.repositorySettings 'sourceLanguage', value

  updateTarget: (event) ->
    value = $(event.target).val() or null
    @app.repositorySettings 'targetLanguage', value
