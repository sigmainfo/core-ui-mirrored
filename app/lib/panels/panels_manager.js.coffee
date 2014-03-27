#= require environment
#= require collections/panels
#= require lib/panels/panel_factory

class Coreon.Lib.Panels.PanelsManager

  @create: (view) =>
    new @
      view: view
      model: Coreon.Collections.Panels.instance()
      factory: Coreon.Lib.Panels.PanelFactory.instance()

  constructor: (options = {}) ->
    @[key] = value for key, value of options
    @initialize()

  initialize: ->
    @model.off null, null, @
    @model.on 'change:widget', @update, @

  removeAll: ->
    @model.forEach (model) ->
      if view = model.view
        view.remove()
        model.view = null
    @model.reset []

  createAll: ->
    @model.load()
    @model.forEach (model) =>
      panel = @factory.create model.get('type'), model
      model.view = panel.render()

  update: ->
    @model.forEach (model) =>
      panel = model.view
      if model.get('widget')
        @view.$('#coreon-widgets').append panel.$el
        panel.widgetize()
      else
        @view.$('#coreon-main').append panel.$el
        panel.maximize()
