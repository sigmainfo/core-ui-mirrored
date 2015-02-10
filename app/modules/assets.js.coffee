#= require environment

Coreon.Modules.Assets =

  saveAssets: (type, model, assets) ->
    d = new $.Deferred()
    if type is 'concept'
      url = Coreon.Helpers.graphUri("/concepts/#{model.get('id')}/properties")
    else
      url = Coreon.Helpers.graphUri("/concepts/#{model.get('concept_id')}/terms/#{model.get('id')}/properties")
    deferredArr = $.map assets, (asset) ->
      formData = new FormData()
      formData.append 'property[key]', asset.key
      formData.append 'property[type]', asset.type
      formData.append 'property[lang]', asset.lang
      formData.append 'property[value]', asset.value
      formData.append 'property[asset]', asset.asset
      Coreon.Modules.CoreAPI.ajax url,
        data: formData,
        processData: false,
        contentType: false,
        type: 'POST'

    $.when.apply(@, deferredArr).then ->
      d.resolve()
    d