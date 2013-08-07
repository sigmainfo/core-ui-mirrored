class Spinach::Features::UserBrowsesRepositoryRootPage < Spinach::FeatureSteps

  include AuthSteps

  step 'I am manager of a repository "The Art of War", "Ancient Chinese military treatise"' do
    # set user_name to mark user as dirty 
    @repo_user.update_attributes roles: ["user", "manager"], user_name: "xxx"
    @repository.update_attributes name: "The Art of War", description: "Ancient Chinese military treatise"
  end

  step 'this repository has the copyright string "(c) 512 BC SunTzu"' do
    @repository.update_attributes copyright: "(c) 512 BC SunTzu"
  end

  step 'it\'s info text reads "Verses from the book occur in modern daily Chinese idioms and phrases."' do
    @repository.update_attributes info: "Verses from the book occur in modern daily Chinese idioms and phrases."
  end

  step 'I visit the repository root page' do
    visit "/#{@repository.id}"
  end

  step 'I should see the title "The Art of War" with description "Ancient Chinese military treatise"' do
    page.should have_css("h2.name", text: "The Art of War")
    page.should have_css("p.description", text: "Ancient Chinese military treatise")
  end

  step 'I should see a table containing the meta data for "CREATED AT", "COPYRIGHT", and "INFO"' do
    page.should have_css("th", text: "CREATED AT")
    page.should have_css("th", text: "COPYRIGHT")
    page.should have_css("th", text: "INFO")
  end

  step 'I should see a section "CONTACT" with my "NAME" and "EMAIL" listed' do
    page.should have_css("h3", text: "CONTACT")
    page.should have_css("th", text: "NAME")
    page.should have_css("td", text: "William Blake")
    page.should have_css("th", text: "EMAIL")
    page.should have_css("td", text: "nobody@blake.com")
  end
end
