#= require environment

submit = (event) ->
  form = $ event.target
  if form.data("xhrForm")?.match /disable/i
    form.find("input,textarea,button").prop "disabled", on
    form.find("a")
      .addClass("disabled")
      .on "click.xhrForms", (event) ->
        event.preventDefault()
        event.stopPropagation()

cancel = (eventm, form) ->
  if form.data("xhrForm")?.match /disable/i
    form.find("input,textarea,button").prop "disabled", off
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
