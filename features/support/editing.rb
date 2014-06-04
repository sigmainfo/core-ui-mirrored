require_relative 'Navigation'

module Editing
  include Navigation

  def edit_concept_details(concept)
    visit_concept_details_page concept
    click_link 'Edit mode'
  end
end
