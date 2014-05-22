#= require environment
#= require modules/language_sections
#= require templates/terms/edit_terms

class Coreon.Views.Terms.EditTermsView extends Backbone.View

  _(@::).extend Coreon.Modules.LanguageSections

  className: 'edit terms'

  initialize: (options = {}) ->
    @template = options.template or Coreon.Templates['terms/edit_terms']
    @app      = options.app      or Coreon.application

  render: ->
    languages = @langs @model.langs(), @app.langs(), @app.get('langs')
    @$el.html @template languages: languages
    @
