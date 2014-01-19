#= require spec_helper
#= require modules/helpers
#= require modules/path

describe 'Coreon.Modules.Path', ->

  before ->
    class Coreon.Models.ModelWithPath extends Backbone.Model
      Coreon.Modules.include @, Coreon.Modules.Path
      defaults: -> {}

  after ->
    delete Coreon.Models.ModelWithPath

  beforeEach ->
    @model = new Coreon.Models.ModelWithPath

  beforeEach ->
    repository = new Backbone.Model
    repository.path = -> '/123456789'
    Coreon.application = repository: -> repository

  afterEach ->
    delete Coreon.application

  describe '#repositoryPath()', ->

    it 'retrieves path from current repository', ->
      Coreon.application.repository().path = -> '/my-repo-123'
      path = @model.repositoryPath()
      expect( path ).to.equal '/my-repo-123'

  describe '#pathTo()', ->

    it 'prepends repository path', ->
      @model.repositoryPath = -> '/my-repo-123'
      path = @model.pathTo 'concepts'
      expect( path ).to.equal '/my-repo-123/concepts'

    it 'joins fragments', ->
      @model.repositoryPath = -> '/my-repo-123'
      path = @model.pathTo 'concepts', 'edit', 'concept-123'
      expect( path ).to.equal '/my-repo-123/concepts/edit/concept-123'

    it 'normalizes slashes', ->
      @model.repositoryPath = -> '/my-repo-123/'
      path = @model.pathTo '/concepts', 'edit/', '/concept-123'
      expect( path ).to.equal '/my-repo-123/concepts/edit/concept-123'

  describe '#path()', ->

    context 'not persisted', ->

      beforeEach ->
        @model.isNew = -> yes

      it 'creates dummy path when not yet persisted', ->
        path = @model.path()
        expect( path ).to.equal 'javascript:void(0)'

    context 'persisted', ->

      beforeEach ->
        @model.isNew = -> no

      it 'creates full path from fragment and id', ->
        @model.repositoryPath = -> '/my-repo'
        @model.pathName = 'concepts'
        @model.id = '1234'
        path = @model.path()
        expect( path ).to.equal '/my-repo/concepts/1234'
