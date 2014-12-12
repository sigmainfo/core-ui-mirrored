#= require environment

submit = (event) ->
  form = $ event.target
  if form.data("xhrForm")?.match /disable/i
    form.find("input,textarea,button,select").prop "disabled", on
    form.find(".coreon-select").addClass "disabled"
    form.find("a")
      .addClass("disabled")
      .on "click.xhrForms", (event) ->
        event.preventDefault()
        event.stopPropagation()

cancel = (eventm, form) ->
  if form.data("xhrForm")?.match /disable/i
    form.find("input,textarea,button,select").prop "disabled", off
    form.find(".coreon-select").removeClass "disabled"
    form.find("a")
      .removeClass("disabled")
      .unbind "click.xhrForms"

Coreon.Modules.XhrForms =

  xhrFormsOn: ->
    @xhrFormsOff()
    @$el.on "submit.xhrForms", submit
    @$el.on "restore.xhrForms", cancel

  xhrFormsOff: ->
    @$el.off ".xhrForms"
    @$("form a").off ".xhrForms"
