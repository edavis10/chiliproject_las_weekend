require 'redmine'

Redmine::Plugin.register :chiliproject_las_weekend do
  name 'LAS Weekend'
  author 'Eric Davis'
  url "https://projects.littlestreamsoftware.com/"
  author_url 'http://www.littlestreamsoftware.com'
  description 'LAS Weekend'
  version '0.1.0'

  requires_redmine :version_or_higher => '1.0.0'

  permission(:view_my_travel_requests, :my_travel_requests => [:index], :require => :loggedin)
end

Redmine::MenuManager.map :top_menu do |menu|
  # Remove and replace My page with one that disappears for Parents and Children
  menu.delete(:my_page)
  menu.push(:my_page,
            { :controller => 'my', :action => 'page' },
            :if => Proc.new {
              User.current.logged? &&
              (!User.current.child? && !User.current.parent?)
            })

  menu.push(:my_travel_requests,
            { :controller => 'my_travel_requests', :action => 'index' },
            :caption => :text_my_travel_requests,
            :if => Proc.new {
              User.current.logged? && User.current.child?
            })

  menu.push(:my_students_travel,
            { :controller => 'my_travel_requests', :action => 'index' },
            :caption => :text_my_students_travel,
            :if => Proc.new {
              User.current.logged? && User.current.parent?
            })

end

