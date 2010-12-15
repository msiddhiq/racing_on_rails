require File.expand_path("../../../test_helper", __FILE__)

ActionController::Base.prepend_view_path("#{::Rails.root.to_s}/test/files/views")

# :stopdoc:
class AutoCompleteHelperTest < ActionController::TestCase

class FakeController < ApplicationController
  def nil_attribute
    @event = Event.new
    render :template => "fake/event.html.erb"
  end

  def present_attribute
    @event = Event.new(:promoter => Person.create!(:name => "Tony Kic"))
    render :template => "fake/event.html.erb"
  end
end

  tests FakeController
    
  def test_auto_complete_nil_attribute
    get :nil_attribute
    assert_select "input#promoter_auto_complete" do
      assert_select "[value=?]", ""
    end
  end
    
  def test_auto_complete_attribute_present
    get :present_attribute
    assert_select "input#promoter_auto_complete" do
      assert_select "[value=?]", "Tony Kic"
    end
    assert_select "input#event_promoter_id" do
      assert_select "[value=?]", /\d+/
    end
  end
end
