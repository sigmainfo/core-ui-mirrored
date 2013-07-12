#= require jquery
#= require jquery.simulate
#= require sinon
#= require sinon-chai
#= require chai-jquery

jQuery.fx.off = true

before ->
  @session_factory = (state="approved", ttl=3600)->
    session =
      ttl: ttl
      user:
        created_at: "2019-11-15T23:42:00.000Z"
        emails: [ "rick.deckard@tyrell.tld" ]
        name: "Rick Deckard"
        updated_at: "2019-11-15T23:42:00.000Z"
        id: "coffeebabe23coffeebabe42"
        state: state
      auth_token: "e63484d04a8a1b63fc7ad195b5f8c76f15e09b76-9930c5f0-b010-0130-6617-10ddb1bfc530"
      repositories: [{
        id: "51ae05ea64010ca60e00000a"
        account_id: "5188bab464010cf696000001"
        graph_uri: "https://5-9-134-169.coreon.com/"
        name: "Voight"
        cache_id: "51ae096464010ca60e00000c"
        user_email: "rick.deckard@tyrell.tld"
        user_roles: ["user"]
        account_name: "Tyrell"
      }]

after ->
  localStorage.removeItem "session" if Coreon.Models.Session?

