# encoding: utf-8
class Spinach::Features::MaintainerAddsTerm < Spinach::FeatureSteps
  include AuthSteps
  include EditSteps 
  include Api::Graph::Factory

  step 'a concept "top hat" exists' do
    @concept = create_concept properties: [
      { key: "label", value: "top hat" }
    ]
  end

  step 'I am on the show concept page of this concept' do
    page.execute_script "Backbone.history.navigate('concepts/#{@concept['_id']}', { trigger: true })"
  end

  step 'I click "Add term"' do
    click_link "Add term"
  end

  step 'I should see a set of term inputs with labels "Value", "Language"' do
    within ".term.create" do
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I fill in "Value" with "high hat" within term inputs' do
    within ".term.create" do
      fill_in "Value", with: "high hat"
    end
  end

  step 'I fill in "Language" with "en" within term inputs' do
    within ".term.create" do
      fill_in "Language", with: "en"
    end
  end

  step 'I click "Add property" within term inputs' do
    within ".term.create" do
      click_link "Add property"
    end
  end

  step 'I should see a set of property inputs with labels "Key", "Value", "Language"' do
    within ".term.create .property" do
      page.should have_field("Key")
      page.should have_field("Value")
      page.should have_field("Language")
    end
  end

  step 'I fill in "Key" with "status" within property inputs' do
    within ".term.create .property" do
      fill_in "Key", with: "status"
    end
  end

  step 'I fill in "Value" with "pending" within property inputs' do
    within ".term.create .property" do
      fill_in "Value", with: "pending"
    end
  end

  step 'I click "Create term"' do
    click_button "Create term"
  end

  step 'I should see a term "high hat" within language "EN"' do
    page.should have_css(".language.en .term .value", text: "high hat")
  end

  step 'I click "PROPERTIES" within term' do
    within ".language.en .term" do
      find("h3", text: "PROPERTIES").click
    end
  end

  step 'I should see a property "STATUS" for the term with value "pending"' do
    within ".language.en .term .properties" do
      find("th", text: "STATUS").find(:xpath, "./following-sibling::td[1]").should have_text("pending")
    end
  end

  step 'I should see a message \'Successfully created term "high hat".\'' do
    page.should have_css(".notification", text: 'Successfully created term "high hat".')
  end

  step 'I should not see "Create term"' do
    pending 'step not implemented'
  end
end
