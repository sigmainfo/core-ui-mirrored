#= require spec_helper
#= require helpers/action_for

describe "Coreon.Helpers.action_for()", ->

  template = null
  helper = null

  beforeEach ->
    sinon.stub I18n, "t"
    template = sinon.stub Coreon.Templates, 'helpers/action_for'
    helper = Coreon.Helpers.action_for

  afterEach ->
    Coreon.Templates['helpers/action_for'].restore()
    I18n.t.restore()

  context = (template) ->
    template.firstCall.args[0]

  it 'returns rendered template', ->
    template.returns '<a href="#">do something</a>'
    markup = helper 'concept.toggle_edit_mode'
    expect(markup).to.equal '<a href="#">do something</a>'

  it 'passes label to template', ->
    I18n.t
      .withArgs('concept.toggle_edit_mode.label')
      .returns 'Toggle'
    helper 'concept.toggle_edit_mode'
    expect(context template).to.have.property 'label', 'Toggle'

  it 'defines fallback for label', ->
    I18n.t
      .withArgs('concept.toggle_edit_mode')
      .returns 'Toggle'
    I18n.t
      .withArgs('concept.toggle_edit_mode.label', defaultValue: 'Toggle')
      .returns 'Toggle'
    helper 'concept.toggle_edit_mode'
    expect(context template).to.have.property 'label', 'Toggle'

  it 'passes hint to template', ->
    I18n.t
      .withArgs('concept.toggle_edit_mode.hint')
      .returns 'Click to toggle'
    helper 'concept.toggle_edit_mode'
    expect(context template).to.have.property 'hint', 'Click to toggle'

  it 'defines fallback for hint', ->
    I18n.t
      .withArgs('concept.toggle_edit_mode.label')
      .returns 'Toggle'
    I18n.t
      .withArgs('concept.toggle_edit_mode.hint', defaultValue: 'Toggle')
      .returns 'Toggle'
    helper 'concept.toggle_edit_mode'
    expect(context template).to.have.property 'hint', 'Toggle'

  it 'passes name to template', ->
    helper 'concept.toggle_edit_mode'
    expect(context template).to.have.property 'name', 'toggle-edit-mode'

  it 'appends additional class to name', ->
    helper 'concept.toggle_edit_mode', className: 'button'
    expect(context template).to.have.property 'name', 'toggle-edit-mode button'
