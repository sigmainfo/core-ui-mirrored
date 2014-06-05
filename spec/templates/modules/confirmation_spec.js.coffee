#= require spec_helper
#= require templates/modules/confirmation

describe 'Coreon.Templates[modules/confirmation]', ->

  template = Coreon.Templates['modules/confirmation']
  data = null

  beforeEach ->
    data =
      message: ''

  render = ->
    $ template data

  it 'renders shim', ->
    el = render()
    expect(el).to.have.class 'modal-shim'

  it 'renders message', ->
    data.message = 'Are you sure?'
    el = render()
    message = el.find '.message'
    expect(message).to.exist
    expect(message).to.have.text 'Are you sure?'

  it 'renders cancel action', ->
    I18n.t.withArgs('confirmation.cancel').returns 'Cancel'
    el = render()
    cancel = el.find 'a.cancel'
    expect(cancel).to.exist
    expect(cancel).to.have.text 'Cancel'

  it 'renders confirmation action', ->
    I18n.t.withArgs('confirmation.confirm').returns 'OK'
    el = render()
    confirm = el.find 'a.confirm'
    expect(confirm).to.exist
    expect(confirm).to.have.text 'OK'
