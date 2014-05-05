#= require spec_helper
#= require helpers/action_for

describe "Coreon.Helpers.action_for()", ->

  template = null
  helper = null

  beforeEach ->
    #TODO 140505 [tc] always stub I18n.t
    sinon.stub I18n, "t"

    #TODO 140505 [tc] always stub all templates
    template = sinon.stub Coreon.Templates, 'helpers/action_for'

    helper = Coreon.Helpers.action_for

  afterEach ->
    Coreon.Templates['helpers/action_for'].restore()
    I18n.t.restore()

  it 'returns rendered template', ->
    template.returns '<a href="#">do something</a>'
    markup = helper 'concept.toggle_edit_mode'
    expect(template).to.have.been.calledOnce
    expect(markup).to.equal '<a href="#">do something</a>'

  it 'passes title to template', ->
    I18n.t.withArgs('concept.toggle_edit_mode').returns 'Toggle'
    helper 'concept.toggle_edit_mode'
    context = template.firstCall.args[0]
    expect(context).to.have.property 'title', 'Toggle'

  it 'passes name to template', ->
    helper 'concept.toggle_edit_mode'
    context = template.firstCall.args[0]
    expect(context).to.have.property 'name', 'toggle-edit-mode'

  it 'appends additional class to name', ->
    helper 'concept.toggle_edit_mode', className: 'button'
    context = template.firstCall.args[0]
    expect(context).to.have.property 'name', 'toggle-edit-mode button'
