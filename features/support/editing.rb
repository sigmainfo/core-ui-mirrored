require_relative 'Navigation'

module Editing
  include Navigation

  def edit_concept_details(concept)
    visit_concept_details_page concept
    click_link 'Edit mode'
  end

  def confirm_edit
    within :confirmation_dialog do
      click_link 'OK'
    end
  end

  def cancel_edit
    within :confirmation_dialog do
      click_link 'Cancel'
    end
  end
end
