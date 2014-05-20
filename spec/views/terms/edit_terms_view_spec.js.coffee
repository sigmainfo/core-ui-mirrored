#= require spec_helper
#= require views/terms/edit_terms_view

describe 'Coreon.Views.Terms.EditTermsView', ->

  template = null
  view = null

  beforeEach ->
    template = @stub().returns ''
    view = new Coreon.Views.Terms.EditTermsView template: template

  it 'is a Backbone view', ->
    expect(view).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    el = view.$el
    expect(el).to.have.class 'terms'
    expect(el).to.have.class 'edit'

  describe '#initialize()', ->

    it 'assigns template from options', ->
      template2 = -> ''
      view.initialize template: template2
      assigned = view.template
      expect(assigned).to.equal template2

    it 'assigns default template when not given', ->
      template2 = @stub Coreon.Templates, 'terms/edit_terms'
      view.initialize()
      assigned = view.template
      expect(assigned).to.equal template2

  describe '#render()', ->

    el = null

    beforeEach ->
      el = view.$el

    it 'can be chained', ->
      result = view.render()
      expect(result).to.equal view

    it 'updates markup', ->
      el.html '<div class="old">update me</div>'
      view.render()
      expect(el).to.not.have '.old'

    it 'inserts markup from template', ->
      template.returns '''
        <ul class="terms">
          <li class="term">foo</li>
        </ul>
      '''
      view.render()
      expect(el).to.have 'ul.terms li.term'
