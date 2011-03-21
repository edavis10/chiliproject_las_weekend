require 'test_helper'

class TravelRequestsTest < ActionController::IntegrationTest
  def setup
    configure_ldap_user_family
  end

  context "logged in as a student" do
    should "see a top menu item for 'My Travel Requests'"
    should "not see a top menu item for 'My Page'"
    context "when clicking the 'My Travel Requests' link" do
      should "end up on the issues page"
      should "show open issues"
      should "show issues authored by me"
    end
  end
  
  context "logged in as a parent" do
    should "see a top menu item for 'My Students' Travel'"
    should "not see a top menu item for 'My Page'"
    context "when clicking the 'My Students' Travel' link" do
      should "end up on the issues page"
      should "show open issues"
      should "show issues authored by my child"
    end
  end

  context "logged in as a normal user (not parent or child)" do
    should "see a top menu item for 'My Page'"
    should "not see a top menu item for 'My Travel Requests'"
    should "not see a top menu item for 'My Students' Requests'"
  end
  
end
