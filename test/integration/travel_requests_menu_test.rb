require 'test_helper'

class TravelRequestsTest < ActionController::IntegrationTest
  def setup
    @project = Project.generate!
    @role = Role.generate!(:permissions => [:view_issues])
    configure_ldap_user_family
    @child = generate_child_user(:password => 'test', :password_confirmation => 'test')
    User.add_to_project(@child, @project, @role)
    @parent = generate_parent_user(:password => 'test', :password_confirmation => 'test')
    User.add_to_project(@parent, @project, @role)
    @child.reload
    @parent.reload
  end

  context "logged in as a student" do
    setup do
      login_as(@child.login, 'test')
      visit_home
    end
    
    should "see a top menu item for 'My Travel Requests'" do
      assert find("#top-menu li a", :text => "My Travel Requests")
    end
    
    should "not see a top menu item for 'My Page'" do
      assert has_no_content?("My page")
    end
    
    context "when clicking the 'My Travel Requests' link" do
      setup do
        click_link "My Travel Requests"
        assert_response :success
      end
      
      should "end up on the issues page" do
        assert_equal "/issues", current_path
      end

      should "show open issues" do
        assert_equal "o", find("#operators_status_id").value
      end
      
      should "show issues authored by me" do
        assert_equal "me", find("#values_author_id").value
      end

    end
  end
  
  context "logged in as a parent" do
    setup do
      login_as(@parent.login, 'test')
      visit_home
    end

    should "see a top menu item for 'My Students' Travel'" do
      assert find("#top-menu li a", :text => "My Students' Travel")
    end

    should "not see a top menu item for 'My Page'" do
      assert has_no_content?("My page")
    end
    
    context "when clicking the 'My Students' Travel' link" do
      setup do
        click_link "My Students' Travel"
        assert_response :success
      end

      should "end up on the issues page" do
        assert_equal "/issues", current_path
      end
      
      should "show open issues" do
        assert_equal "o", find("#operators_status_id").value
      end
      
      should "show issues authored by my child" do
        assert_equal @child.id.to_s, find("#values_author_id").value
      end
      
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
