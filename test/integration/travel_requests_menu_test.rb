require 'test_helper'

class TravelRequestsTest < ActionController::IntegrationTest
  def setup
    configure_ldap_user_family
  end

  context "logged in as a student" do
    setup do
      @user = generate_child_user(:password => 'test', :password_confirmation => 'test')
      login_as(@user.login, 'test')
      visit_home
    end
    
    should "see a top menu item for 'My Travel Requests'" do
      assert find("#top-menu li a", :text => "My Travel Requests")
    end
    
    should "not see a top menu item for 'My Page'" do
      assert has_no_content?("My page")
    end
    
    context "when clicking the 'My Travel Requests' link" do
      should "end up on the issues page"
      should "show open issues"
      should "show issues authored by me"
    end
  end
  
  context "logged in as a parent" do
    setup do
      @user = generate_parent_user(:password => 'test', :password_confirmation => 'test')
      login_as(@user.login, 'test')
      visit_home
    end

    should "see a top menu item for 'My Students' Travel'" do
      assert find("#top-menu li a", :text => "My Students' Travel")
    end

    should "not see a top menu item for 'My Page'" do
      assert has_no_content?("My page")
    end
    
    context "when clicking the 'My Students' Travel' link" do
      should "end up on the issues page"
      should "show open issues"
      should "show issues authored by my child"
    end
  end

  context "logged in as a normal user (not parent or child)" do
    setup do
      @user = User.generate!(:password => 'test', :password_confirmation => 'test')
      login_as(@user.login, 'test')
      visit_home
    end
    
    should "see a top menu item for 'My Page'" do
      assert find("#top-menu li a", :text => "My page")
    end
    
    should "not see a top menu item for 'My Travel Requests'" do
      assert has_no_content?("My Travel Requests")
    end
    
    should "not see a top menu item for 'My Students' Requests'" do
      assert has_no_content?("My Students' Requests")
    end
    
  end
  
end
