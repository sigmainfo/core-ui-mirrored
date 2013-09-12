# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# me = Api::Auth::User.find_or_create_by name: "William Blake"
# me.login = "Nobody"
# me.password = me.password_confirmation = "se7en!"
# me.save!
# 
# Api::Graph::Concept.delete_all
# Api::Graph::Term.delete_all
# Api::Graph::Taxonomy.delete_all
# Api::Graph::TaxonomyNode.delete_all
# 
# %w|Zitrone Limone Frucht poetisch Poebene Poem Poet Weihnachtsgedicht Osterreim Muttertagsgedicht Auszählreim|.each_with_index do |value, index|
#   concept = Api::Graph::Concept.create!
#   concept.properties.create! key: "label", value: value
#   concept.properties.create! key: "definition", value: "A #{value} is a #{value} is a #{value}" if [0, 3, 4, 5].include? index
#   concept.terms.create! value: value, lang: "de"
#   concept.terms.create! value: "poetic", lang: "en" if value == "poetisch"
# end
# 
# %w|lemon poet poetise poem dead man poetry poeple poenology|.each_with_index do |value, index|
#   concept = Api::Graph::Concept.create!
#   concept.properties.create! key: "label", value: value
#   concept.terms.create! value: value, lang: "en"
#   if value == 'poem'
#     concept.properties.create! key: "definition", value: "A poem is a form of literary art in which language is used for its aesthetic and evocative qualities.", lang: "en"
#     concept.properties.create! key: "definition", value: "Mit dem Begriff „Gedicht“ wurde ursprünglich alles schriftlich Abgefasste bezeichnet. Auch hier fand im 18. Jahrhundert eine Begriffsfestigung statt: Seitdem wird der Begriff nur noch für den poetischen Bereich verwendet.", lang: "de"
#     concept.properties.create! key: "notes", value: "BITTE ÜBERPRÜFEN !"
#     concept.properties.create! key: "notes", value: "I am dead, am I?"
#     concept.properties.create! key: "status", value: "accepted", lang: "en"
#     concept.terms.create! value: "Gedicht", lang: "de"
#     term = concept.terms.create! value: "Sonett", lang: "de", source: "http://iate.eunion.polit"
#     term.properties.create! key: "gender", value: "n"
#     concept.terms.create! value: "Sonette", lang: "fr"
#   end
# end
# 
# 
# poem = Api::Graph::Concept.elem_match(properties: { value: "poem" }).first
# superconcept = Api::Graph::Concept.elem_match(properties: { value: "poetry" }).first
# poem.superconcepts << superconcept
# poem.subconcepts = Api::Graph::Term.where(:value.in => %w|Weihnachtsgedicht Osterreim Muttertagsgedicht Auszählreim|).map {|t| t.concept}
# poem.save!
# 
# taxonomy = Api::Graph::Taxonomy.create! name: "Professions"
# %w|poet poetry editor artist|.each do |name|
#   taxonomy.nodes.create! name: name
#   taxonomy.save!
# end
