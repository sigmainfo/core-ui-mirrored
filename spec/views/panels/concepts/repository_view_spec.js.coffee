#= require spec_helper
#= require views/panels/concepts/repository_view

describe "Coreon.Views.Panels.Concepts.RepositoryView", ->

  beforeEach ->
    Coreon.application = new Backbone.Model
    Coreon.application.set 'repository',
      path: -> "/coffee23"
    Coreon.application.lang = -> 'en'
    Coreon.application.langs = -> []

    # Coreon.Helpers.repositoryPath = -> "/coffee23/concepts/new"
    @view = new Coreon.Views.Panels.Concepts.RepositoryView
      model: new Backbone.Model managers: []
    sinon.stub I18n, "t"

  afterEach ->
    I18n.t.restore()

  it "is a Backbone view", ->
    @view.should.be.an.instanceof Backbone.View

  describe "render()", ->

    beforeEach ->
      Coreon.Helpers.can = -> true

    afterEach ->
      Coreon.application = null

    it "is chainable", ->
      @view.render().should.equal @view

    it "renders title", ->
      @view.model.set "name", "The Art of War", silent: on
      @view.render()
      @view.$el.should.have "h2.name"
      @view.$("h2.name").should.have.text "The Art of War"

    it "renders description", ->
      @view.model.set "description", "Chinese military treatise", silent: on
      @view.render()
      @view.$el.should.have "p.description"
      @view.$("p.description").should.have.text "Chinese military treatise"

    it "renders meta data", ->
      sinon.stub I18n, 'l'
      I18n.l.withArgs('date.formats.default', '2013-06-17T09:46:52.297Z').returns '2013-06-17'
      try
        I18n.t.withArgs("repository.created").returns "Created at"
        I18n.t.withArgs("repository.copyright").returns "Copyright"
        I18n.t.withArgs("repository.info").returns "Info"
        I18n.t.withArgs("repository.languages").returns "Languages"
        I18n.t.withArgs("languages.en").returns "English"
        I18n.t.withArgs("languages.de").returns "German"
        I18n.t.withArgs("languages.fr").returns "French"
        Coreon.application.langs = -> ['en', 'de', 'fr']

        @view.model.set
          created_at: "2013-06-17T09:46:52.297Z"
          copyright: "(c) 512 BC SunTzu"
          info: "Verses from the book occur in modern daily Chinese idioms and phrases."
        @view.render()

        @view.$el.should.have "table th"

        @view.$("table tr:eq(0) th").should.have.text "Created at"
        @view.$("table tr:eq(0) td").should.have.text "2013-06-17"

        @view.$("table tr:eq(1) th").should.have.text "Copyright"
        @view.$("table tr:eq(1) td").should.have.text "(c) 512 BC SunTzu"

        @view.$("table tr:eq(2) th").should.have.text "Info"
        @view.$("table tr:eq(2) td").should.have.text  "Verses from the book occur in modern daily Chinese idioms and phrases."

        @view.$("table tr:eq(3) th").should.have.text "Languages"
        @view.$("table tr:eq(3) td").should.have.text  "English (en), German (de), French (fr)"
      finally
        I18n.l.restore()

    it "renders contact information", ->
      I18n.t.withArgs("repository.contact").returns "Contact"
      I18n.t.withArgs("user.name").returns "Name"
      I18n.t.withArgs("user.email").returns "Email"
      @view.model.set "managers", [ ["Sun Tzu", "tzu@sun.com"], ["Wei Liaozi", "wl@oracle.com"]]
      @view.render()
      @view.$el.should.have "section.contact h3"
      @view.$("section.contact h3").should.have.text "Contact"
      @view.$("section.contact").should.have "table.managers tr"
      @view.$("section.contact table.managers tr").should.have.lengthOf 3

      @view.$("section.contact table.managers tr:eq(0) th:eq(0)").should.have.text "Name"
      @view.$("section.contact table.managers tr:eq(0) th:eq(1)").should.have.text "Email"

      @view.$("section.contact table.managers tr:eq(1) td:eq(0)").should.have.text "Sun Tzu"
      @view.$("section.contact table.managers tr:eq(1) td:eq(1) a").should.have.attr "href", "mailto:tzu@sun.com"
      @view.$("section.contact table.managers tr:eq(1) td:eq(1) a").should.have.text "tzu@sun.com"

      @view.$("section.contact table.managers tr:eq(2) td:eq(0)").should.have.text "Wei Liaozi"
      @view.$("section.contact table.managers tr:eq(2) td:eq(1) a").should.have.attr "href", "mailto:wl@oracle.com"
      @view.$("section.contact table.managers tr:eq(2) td:eq(1) a").should.have.text "wl@oracle.com"

    context "with maintainer privileges", ->

      beforeEach ->
        Coreon.Helpers.can = -> true

      it "renders link to new concept form", ->
        @view.render()
        @view.$el.should.have 'a[href="/coffee23/concepts/new/terms/en/"]'

    context "without maintainer privileges", ->

      beforeEach ->
        Coreon.Helpers.can = -> false

      it "does not render link to new concept form", ->
        @view.render()
        @view.$el.should.not.have 'a[href="/coffee23/concepts/new/terms/en/"]'
