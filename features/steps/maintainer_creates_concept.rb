# encoding: utf-8
class MaintainerCreatesConcept < Spinach::FeatureSteps
  include AuthSteps
  include SearchSteps

  step 'I have maintainer privileges' do
    page.execute_script 'Coreon.application.session.ability.set("role", "maintainer");'
  end

  step 'I visit the start page' do
    page.execute_script 'Backbone.history.navigate("/other");'
    page.execute_script 'Backbone.history.navigate("/", {trigger: true});'
  end

  step 'I click on "New concept"' do
    click_link "New concept"
  end

  step 'I should be on the new concept page' do
    page.current_path.should =~ %r|^/concepts/new|
  end

  step 'I should see "<New concept>" within the title' do
    page.should have_css(".concept h2", text: "<New concept>")
  end

  step 'I should see a section "BROADER & NARROWER"' do
    page.should have_css("section h3", text: "BROADER & NARROWER")
  end

  step 'I should see "<New concept>" being the current selection' do
    page.should have_css(".broader-and-narrower .self", text: "<New concept>")
  end

  step 'I should see "Repository" within the list of broader concepts' do
    page.should have_css(".broader-and-narrower .broader li", text: "Repository")
  end

  step 'I should see a new concept node "<New concept>" within the concept map' do
    page.should have_css("#coreon-concept-map .concept-node", text: "<New concept>")
  end

  step 'I click "Create concept"' do
    click_button "Create concept"
  end

  step 'I should be on the show concept page' do
    page.should have_no_css(".concept.new")
    page.current_path.should =~ %r|^/concepts/[0-9a-f]{24}$| 
    @id = current_path.split("/").last
  end

  step 'I should see the id of the newly created concept within the title' do
    page.should have_css(".label", text: @id)
  end

  step 'I should see a new concept node with the id of the newly created concept within the concept map' do
    page.should have_css("#coreon-concept-map .concept-node", text: @id)
  end

  step 'I should see a set of property inputs with labels "Key", "Value", "Language"' do
    within(".property") do
      page.should have_field("Key")
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I should see a set of term inputs with labels "Value", "Language"' do
    within(".term") do
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I click "Add property"' do
    click_link "Add property"
  end

  step 'I click "Add term"' do
    click_link "Add term"
  end

  step 'I click "Remove property" within the set' do
    click_link "Remove property"
  end

  step 'I click "Remove term" within the set' do
    click_link "Remove term"
  end

  step 'I should not see a set of property inputs anymore' do
    page.should have_no_css(".property")
  end

  step 'I should not see a set of term inputs anymore' do
    page.should have_no_css(".term")
  end

  step 'I fill "Key" with "label"' do
    fill_in "Key", with: "label"
  end

  step 'I fill "Value" with "dead man"' do
    fill_in "Value", with: "dead man"
  end

  step 'I fill "Value" with "corpse"' do
    fill_in "Value", with: "corpse"
  end

  step 'I fill "Language" with "en"' do
    fill_in "Language", with: "en"
  end

  step 'I should see "dead man" within the title' do
    page.should have_css(".concept h2", text: "dead man")
  end

  step 'I should see "corpse" within the title' do
    page.should have_css(".concept h2", text: "corpse")
  end

  step 'I should see a property "LABEL" with value "dead man"' do
    page.should have_css(".properties th", text: "LABEL")
    page.find(:xpath, "//th[text() = 'label']/following-sibling::td").text.should == "dead man"
  end

  step 'client-side validation is turned off' do
    page.execute_script '$("form").attr("novalidate", true)'
  end

  step 'I fill "Value" of term with "corpse"' do
    within(".term") do
      fill_in "Value", with: "corpse"
    end
  end

  step 'I should see an error summary' do
    page.should have_css("form .error-summary")
  end

  step 'this summary should contain "Failed to create concept:"' do
    page.find("form .error-summary").should have_content("Failed to create concept:")
  end

  step 'this summary should contain "2 errors on properties"' do
    page.find("form .error-summary").should have_content("2 errors on properties")
  end

  step 'this summary should contain "1 error on terms"' do
    page.find("form .error-summary").should have_content("1 error on terms")
  end

  step 'I should see error "can\'t be blank" for property input "Key"' do
    page.should have_css(".property .key .error-message", text: "can\'t be blank")
  end

  step 'I should see error "can\'t be blank" for property input "Value"' do
    page.should have_css(".property .value .error-message", text: "can\'t be blank")
  end

  step 'I should see error "can\'t be blank" for term input "Language"' do
    page.should have_css(".term .lang .error-message", text: "can\'t be blank")
  end

  step 'I click "Remove property"' do
    click_link "Remove property"
  end

  step 'I fill "Language" of term with "en"' do
    fill_in "Language", with: "en"
  end
  
  step 'I should not see an error summary' do
    page.should have_no_css("form .error-summary")
  end

  step 'I click "Cancel"' do
    click_link "Cancel"
  end 

  step 'I should be on the start page again' do
    page.current_path.should == "/"
  end

  step 'I should not see "<New concept>"' do
    page.should have_no_content("<New concept>")
  end

  step 'I should see link "New concept"' do
    page.should have_link("New concept")
  end

  step 'I should see an English term "corpse"' do
    page.should have_css(".terms .language.en .term h4", text: "corpse")
  end

  step 'I do a search for "corpse"' do
    within "#coreon-search" do
      fill_in "coreon-search-query", with: "corpse"
      find('input[type="submit"]').click
    end
  end

  step 'I should see a set of term inputs' do
    page.should have_css("form .term input")
  end

  step 'I should see "corpse" for "Value"' do
    page.should have_field("Value", with: "corpse")
  end

  step 'I should see "en" for "Language"' do
    page.should have_field("Language", with: "en")
  end

  step 'I should see message \'Successfully created concept "corpse".\'' do
    page.should have_css(".notification", text: 'Successfully created concept "corpse".')
  end

  step 'I do not have maintainer privileges' do
    page.execute_script 'Coreon.application.session.ability.set("role", "user");'
  end

  step 'I should not see link "New concept"' do
    page.should have_no_link("New concept")
  end

  step 'I visit "/concepts/new"' do
    visit "/concepts/new"
  end

  step 'I should be on the start page' do
    page.current_path.should == "/"
  end
end
