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

Coreon.Modules.XhrForms =

  xhrFormsOn: ->
    @xhrFormsOff()
    @$el.on "submit.xhrForms", submit

  xhrFormsOff: ->
    @$el.off ".xhrForms"
    @$("form a").off ".xhrForms"
