# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path


require 'capybara/rails'


def User.add_to_project(user, project, role)
  Member.generate!(:principal => user, :project => project, :roles => [role])
end

module ChiliProjectIntegrationTestHelper
  def login_as(user="existing", password="existing")
    visit "/login"
    fill_in 'Login', :with => user
    fill_in 'Password', :with => password
    click_button 'Login'
    assert_response :success
    assert User.current.logged?
  end

  def visit_home
    visit '/'
    assert_response :success
  end

  def visit_project(project)
    visit '/'
    assert_response :success

    click_link 'Projects'
    assert_response :success

    click_link project.name
    assert_response :success
  end

  def visit_issue_page(issue)
    visit '/issues/' + issue.id.to_s
  end

  def visit_issue_bulk_edit_page(issues)
    visit url_for(:controller => 'issues', :action => 'bulk_edit', :ids => issues.collect(&:id))
  end

  
  # Capybara doesn't set the response object so we need to glue this to
  # it's own object but without @response
  def assert_response(code)
    # Rewrite human status codes to numeric
    converted_code = case code
                     when :success
                       200
                     when :missing
                       404
                     when :redirect
                       302
                     when :error
                       500
                     when code.is_a?(Symbol)
                       ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[code]
                     else
                       code
                     end

    assert_equal converted_code, page.status_code
  end

  

end

class ActionController::IntegrationTest
  include ChiliProjectIntegrationTestHelper
  
  include Capybara
  
end

class ActiveSupport::TestCase
  def assert_forbidden
    assert_response :forbidden
    assert_template 'common/403'
  end

  def configure_plugin(configuration_change={})
    Setting.plugin_TODO = {
      
    }.merge(configuration_change)
  end

  def reconfigure_plugin(configuration_change)
    Settings['plugin_TODO'] = Setting['plugin_TODO'].merge(configuration_change)
  end

  def configure_ldap_user_family_settings(fields={})
    Setting.plugin_redmine_ldap_user_family = fields.stringify_keys
  end

  def configure_ldap_user_family
    @parent_group = Group.generate!(:lastname => 'Parent')
    @child_group = Group.generate!(:lastname => 'Child')
    
    @custom_field = UserCustomField.generate!(:name => 'Student Id', :field_format => 'string')
    @custom_field_alternative_mail = UserCustomField.generate!(:name => 'Alternative Mail', :field_format => 'string')
    @parent_auth_source = AuthSourceLdap.generate!(:name => 'Parent',
                                                   :host => '127.0.0.1',
                                                   :port => 389,
                                                   :base_dn => 'OU=Person,DC=redmine,DC=org',
                                                   :attr_login => 'uid',
                                                   :attr_firstname => 'givenName',
                                                   :attr_lastname => 'sn',
                                                   :attr_mail => 'mail',
                                                   :onthefly_register => true,
                                                   :groups => [@parent_group],
                                                   :custom_attributes => {
                                                     @custom_field.id.to_s => 'employeeNumber',
                                                     @custom_field_alternative_mail.id.to_s => 'mail'
                                                   })

    @child_auth_source = AuthSourceLdap.generate!(:name => 'Child',
                                                  :host => '127.0.0.1',
                                                  :port => 389,
                                                  :base_dn => 'OU=Person,DC=redmine2,DC=org',
                                                  :attr_login => 'uid',
                                                  :attr_firstname => 'givenName',
                                                  :attr_lastname => 'sn',
                                                  :attr_mail => 'mail',
                                                  :onthefly_register => true,
                                                  :groups => [@child_group],
                                                  :custom_attributes => {
                                                    @custom_field.id.to_s => 'employeeNumber',
                                                    @custom_field_alternative_mail.id.to_s => 'mail'
                                                  })
    configure_ldap_user_family_settings({
                                          'family_custom_field' => @custom_field.id.to_s,
                                          'parent_email_override_field' => @custom_field_alternative_mail.id.to_s,
                                          'child_group_id' => @child_group.id.to_s,
                                          'parent_group_id' => @parent_group.id.to_s
                                        })
  end

  def generate_parent_user(attrs={})
    u = User.generate_with_protected!({:custom_field_values => {@custom_field.id.to_s => 'oneusec123'}}.merge(attrs))
    @parent_group.users << u
    u
  end

  def generate_child_user(attrs={})
    u = User.generate_with_protected!({:custom_field_values => {@custom_field.id.to_s => 'oneusec123'}}.merge(attrs))
    @child_group.users << u
    u
  end

end
