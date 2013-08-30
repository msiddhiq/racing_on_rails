require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class StarsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end
  
  def test_create
    event = FactoryGirl.create(:event)
    person = FactoryGirl.create(:person_with_login)
    
    login_as person
    post :create, :star => { :event_id => event.id }, :format => "json"
    
    assert Star.where(:event_id => event.id, :person_id => person.id).exists?, "Should create star for event and person"
  end
  
  def test_index
    get :index, :format => "json"
    fail "test more conditions"
  end
end
