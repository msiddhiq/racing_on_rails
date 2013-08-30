require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class EventStarsTest < AcceptanceTest
  def test_stars
    javascript!

    event = FactoryGirl.create(:event)
    star = FactoryGirl.create(:star)
    
    visit "/schedule/list"
    assert page.has_no_selector?("i.icon_star"), "No events should show as starred without login"
    
    login_as star.person

    visit "/schedule/list"
    assert page.has_selector?("i.icon_star"), "Show stars to logged-in person"
    
    # Click star on
    # Reload page
    
    # Click star off
    # reload page
    
    # Click only works if logged-in
    
    # Show hand icon on hover if logged-in

    # homepage
    # schedule
    # account
    # download
    # iCal feed
    # registration open
    # Give better feedback when not logged-in
  end
end
