# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

me = Api::Auth::User.find_or_create_by name: "William Blake"
me.login = "Nobody"
me.password = me.password_confirmation = "se7en!"
me.save!

Api::Graph::Concept.delete_all
Api::Graph::Term.delete_all
Api::Graph::Taxonomy.delete_all
Api::Graph::TaxonomyNode.delete_all

%w|Zitrone Limone Frucht poetisch Poebene Poem Poet|.each_with_index do |value, index|
  concept = Api::Graph::Concept.create!
  concept.properties.create! key: "label", value: value
  concept.terms.create! value: value, lang: "de"
end

%w|lemon poet poetic poetise poem dead man poetry poeple poenology|.each_with_index do |value, index|
  concept = Api::Graph::Concept.create!
  concept.properties.create! key: "label", value: value
  concept.terms.create! value: value, lang: "en"
end

subconcept = Api::Graph::Concept.elem_match(properties: { value: "poem" }).first
superconcept = Api::Graph::Concept.elem_match(properties: { value: "poetry" }).first
subconcept.super_concepts << superconcept
subconcept.save!

taxonomy = Api::Graph::Taxonomy.create! name: "Professions"
%w|poet poetry editor artist|.each do |name|
  taxonomy.nodes.create! name: name
  taxonomy.save!
end
