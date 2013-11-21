#= require spec_helper
#= require views/widgets/languages_view

describe 'Coreon.Views.Widgets.LanguagesView', ->

  beforeEach ->
    Coreon.application = 
      repository: ->
        id: 'my-repo'
        usedLanguages: ->
          ['en', 'de', 'fr']
        on: ->
      repositorySettings: ->
        {}
    
    sinon.stub I18n, 't'

    model = new Backbone.Model
    @view = new Coreon.Views.Widgets.LanguagesView
      model: model

  afterEach ->
    I18n.t.restore()
    delete Coreon.application

  it 'is a Backbone view', ->
    expect( @view ).to.be.an.instanceOf Backbone.View

  it 'creates container', ->
    expect( @view.$el ).to.have.id 'coreon-languages'

  describe 'render()', ->

    it 'can be chained', ->
      expect( @view.render() ).to.equal @view

    it 'renders form', ->
      @view.render()
      expect( @view.$el ).to.have 'form.languages'
      
    describe 'with stubbed repositorySettings', ->
      
      beforeEach ->
        sinon.stub Coreon.application, 'repositorySettings'
        Coreon.application.repositorySettings.withArgs('sourceLanguage').returns 'de'
        Coreon.application.repositorySettings.withArgs('targetLanguage').returns 'fr'
        
      afterEach ->
        Coreon.application.repositorySettings.restore()
        
      it 'sets the source language select to stored value', ->
        @view.render()
        expect( @view.$('select[name=source_language]').val() ).to.equal 'de'
      
      it 'sets the target language select to stored value', ->
        @view.render()
        expect( @view.$('select[name=target_language]').val() ).to.equal 'fr'
      
  describe 'onChangeSourceLanguage', ->
    beforeEach ->
      sinon.spy Coreon.application, 'repositorySettings'
      
    afterEach ->
      Coreon.application.repositorySettings.restore()
    
    it 'stores selected source language on selects change event', ->
      @view.render()
      @view.$('select[name=source_language]').val('fr').change()
      
      expect( Coreon.application.repositorySettings ).to.be.calledWith('sourceLanguage', 'fr')
      
  describe 'onChangeTargetLanguage', ->
    beforeEach ->
      sinon.spy Coreon.application, 'repositorySettings'
      
    afterEach ->
      Coreon.application.repositorySettings.restore()
    
    it 'stores selected target language on selects change event', ->
      @view.render()
      @view.$('select[name=target_language]').val('fr').change()
      
      expect( Coreon.application.repositorySettings ).to.be.calledWith('targetLanguage', 'fr')
      